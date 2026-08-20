#' Automatic Pairwise Test for Continuous Outcomes
#'
#' Performs unpaired, two-sample comparisons of a continuous outcome for every
#' pair of groups. It automatically selects Welch's t-test when neither group's
#' Shapiro-Wilk test rejects normality (p > 0.05), or the Wilcoxon rank-sum test
#' otherwise.
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
#' This function is for **independent samples**: each row represents one
#' independent observational unit, and each unit belongs to exactly one group.
#' It does not pair or match rows across groups and is not appropriate for
#' repeated measures, before/after data, or other paired observations.
#'
#' After rows with `NA` in either `outcome` or `group` are removed, all unique
#' two-group combinations are generated. For each combination, the function:
#'
#' 1. uses the observations from the two groups as independent samples;
#' 2. looks up the Shapiro-Wilk p-value computed once on each complete group;
#' 3. uses Welch's two-sample t-test if both p-values are available and greater
#'    than 0.05, or the two-sample Wilcoxon rank-sum test otherwise; and
#' 4. returns the selected test's two-sided, unadjusted p-value.
#'
#' Shapiro-Wilk is only evaluated for group sizes from 3 through 5,000. A
#' p-value greater than 0.05 means normality was not rejected; it does not prove
#' that the data are normally distributed. Comparisons can share a group, so
#' the rows of the returned result are not themselves statistically independent.
#' No adjustment for multiple comparisons is applied.
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
