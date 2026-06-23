#' Automatic Pairwise Test for Continuous Outcomes
#'
#' Performs pairwise group comparisons on a continuous outcome, automatically
#' selecting Welch t-test when both groups pass Shapiro-Wilk normality (p > 0.05)
#' or Wilcoxon rank-sum test otherwise.
#'
#' @param data A data frame.
#' @param outcome <[`data-masking`][dplyr::dplyr_data_masking]> Unquoted name of
#'   the continuous outcome column.
#' @param group <[`data-masking`][dplyr::dplyr_data_masking]> Unquoted name of
#'   the grouping column.
#'
#' @return A tibble with one row per group pair, containing:
#'   \describe{
#'     \item{group_1, group_2}{Group labels for the pair.}
#'     \item{n_1, n_2}{Sample sizes per group.}
#'     \item{shapiro_p_1, shapiro_p_2}{Shapiro-Wilk p-values (NA if n < 3 or n > 5000).}
#'     \item{test_used}{Either `"Welch t-test"` or `"Wilcoxon rank-sum"`.}
#'     \item{p_value}{Two-sided p-value from the selected test.}
#'   }
#'
#' @details
#' Shapiro-Wilk is run per group on the full dataset (not just the pair). Both
#' groups must have a valid, significant normality p-value (> 0.05) for the
#' t-test to be used; otherwise Wilcoxon is used. Rows with `NA` in either
#' `outcome` or `group` are dropped before analysis.
#'
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   value = c(rnorm(20, 5), rnorm(20, 6), rnorm(20, 5.5)),
#'   grp   = rep(c("A", "B", "C"), each = 20)
#' )
#' pairwise_auto_test(df, value, grp)
#' @importFrom stats shapiro.test t.test wilcox.test
#' @importFrom utils combn
#' @importFrom dplyr select filter summarise n
#' @importFrom purrr map_dfr
#' @importFrom rlang enquo `!!`
#' @importFrom tidyr drop_na
#' @importFrom tibble tibble
#' @export
pairwise_auto_test <- function(data, outcome, group) {
  outcome <- enquo(outcome)
  group   <- enquo(group)

  df <- data |>
    select(
      outcome = !!outcome,
      group   = !!group
    ) |>
    drop_na()

  # Normality table (computed once across all groups)
  normality_tbl <- df |>
    summarise(
      n = n(),
      shapiro_p = ifelse(
        n >= 3 & n <= 5000,
        shapiro.test(outcome)$p.value,
        NA_real_
      ),
      .by = group
    )

  groups <- unique(df$group)

  results <- combn(groups, 2, simplify = FALSE) |>
    map_dfr(function(pair) {
      pair_df <- df |> filter(group %in% pair)

      g1_info <- normality_tbl |> filter(group == pair[1])
      g2_info <- normality_tbl |> filter(group == pair[2])

      both_normal <-
        !is.na(g1_info$shapiro_p) &
        !is.na(g2_info$shapiro_p) &
        g1_info$shapiro_p > 0.05 &
        g2_info$shapiro_p > 0.05

      if (both_normal) {
        test_res  <- t.test(outcome ~ group, data = pair_df)
        test_used <- "Welch t-test"
      } else {
        test_res  <- wilcox.test(outcome ~ group, data = pair_df, exact = FALSE)
        test_used <- "Wilcoxon rank-sum"
      }

      tibble(
        group_1     = pair[1],
        n_1         = g1_info$n,
        shapiro_p_1 = g1_info$shapiro_p,
        group_2     = pair[2],
        n_2         = g2_info$n,
        shapiro_p_2 = g2_info$shapiro_p,
        test_used   = test_used,
        p_value     = test_res$p.value
      )
    })

  results
}
