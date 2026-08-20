#' Automatic Pairwise Test for Paired Continuous Outcomes
#'
#' Performs paired, two-sample comparisons of a continuous outcome for every
#' pair of measurement groups. It automatically selects the paired t-test when
#' the within-pair differences do not reject Shapiro-Wilk normality (p > 0.05),
#' or the Wilcoxon signed-rank test otherwise.
#'
#' @param data A data frame.
#' @param outcome <[`data-masking`][dplyr::dplyr_data_masking]> Unquoted name of
#'   the continuous outcome column.
#' @param group <[`data-masking`][dplyr::dplyr_data_masking]> Unquoted name of
#'   the measurement-group or condition column.
#' @param pair_id <[`data-masking`][dplyr::dplyr_data_masking]> Unquoted name of
#'   the column that identifies paired observations, such as participant ID.
#'
#' @return A tibble with one row per group pair, containing:
#'   \describe{
#'     \item{group_1, group_2}{Group labels for the comparison.}
#'     \item{n_pairs}{Number of complete matched pairs used.}
#'     \item{shapiro_p_difference}{Shapiro-Wilk p-value for the within-pair
#'       differences (`NA` when `n_pairs` is outside 3 through 5,000 or all
#'       differences are identical).}
#'     \item{test_used}{Either `"Paired t-test"` or
#'       `"Wilcoxon signed-rank"`.}
#'     \item{p_value}{Two-sided, unadjusted p-value from the selected test.}
#'   }
#'
#' @details
#' Each `pair_id` must have at most one non-missing observation in each group.
#' Rows with `NA` in `outcome`, `group`, or `pair_id` are removed first. For
#' each group combination, only IDs observed in both groups are retained; IDs
#' present in only one group do not contribute to that comparison.
#'
#' For each group pair, the function:
#'
#' 1. matches observations by `pair_id`;
#' 2. calculates `group_1 - group_2` within each matched pair;
#' 3. uses the paired t-test if the Shapiro-Wilk p-value for those differences
#'    is available and greater than 0.05, or the Wilcoxon signed-rank test
#'    otherwise; and
#' 4. returns the selected test's two-sided, unadjusted p-value.
#'
#' The paired t-test assumes that the within-pair differences are approximately
#' normally distributed. A Shapiro-Wilk p-value above 0.05 means normality was
#' not rejected; it does not prove normality. No multiple-comparison adjustment
#' is applied. The Wilcoxon signed-rank test additionally assumes a symmetric
#' distribution of within-pair differences.
#'
#' @examples
#' set.seed(7)
#' paired_df <- data.frame(
#'   id = rep(1:20, times = 2),
#'   visit = rep(c("before", "after"), each = 20),
#'   score = c(rnorm(20, 10, 2), rnorm(20, 12, 2))
#' )
#' pairwise_auto_paired_test(paired_df, score, visit, id)
#'
#' @importFrom stats shapiro.test t.test wilcox.test
#' @importFrom utils combn
#' @importFrom dplyr select
#' @importFrom purrr map_dfr
#' @importFrom rlang enquo `!!`
#' @importFrom tidyr drop_na
#' @importFrom tibble tibble
#' @export
pairwise_auto_paired_test <- function(data, outcome, group, pair_id) {
  outcome <- enquo(outcome)
  group   <- enquo(group)
  pair_id <- enquo(pair_id)

  df <- data |>
    select(
      outcome = !!outcome,
      group   = !!group,
      pair_id = !!pair_id
    ) |>
    drop_na()

  duplicate_rows <- duplicated(df[c("pair_id", "group")])
  if (any(duplicate_rows)) {
    stop(
      "Each pair_id must have at most one observation in each group after missing values are removed.",
      call. = FALSE
    )
  }

  groups <- unique(df$group)

  combn(groups, 2, simplify = FALSE) |>
    map_dfr(function(pair) {
      group_1_df <- df[df$group == pair[1], c("pair_id", "outcome")]
      group_2_df <- df[df$group == pair[2], c("pair_id", "outcome")]

      matched <- merge(
        group_1_df,
        group_2_df,
        by = "pair_id",
        suffixes = c("_1", "_2"),
        sort = FALSE
      )

      n_pairs <- nrow(matched)
      if (n_pairs == 0) {
        stop(
          "Every group comparison must contain at least one complete matched pair.",
          call. = FALSE
        )
      }

      differences <- matched$outcome_1 - matched$outcome_2
      shapiro_p <- if (
        n_pairs >= 3 &&
        n_pairs <= 5000 &&
        length(unique(differences)) > 1
      ) {
        shapiro.test(differences)$p.value
      } else {
        NA_real_
      }

      differences_normal <- !is.na(shapiro_p) && shapiro_p > 0.05

      if (differences_normal) {
        test_res <- t.test(
          matched$outcome_1,
          matched$outcome_2,
          paired = TRUE
        )
        test_used <- "Paired t-test"
      } else {
        test_res <- wilcox.test(
          matched$outcome_1,
          matched$outcome_2,
          paired = TRUE,
          exact = FALSE
        )
        test_used <- "Wilcoxon signed-rank"
      }

      tibble(
        group_1              = pair[1],
        group_2              = pair[2],
        n_pairs              = n_pairs,
        shapiro_p_difference = shapiro_p,
        test_used            = test_used,
        p_value              = test_res$p.value
      )
    })
}
