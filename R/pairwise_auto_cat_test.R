
#' Automatic Pairwise Test for Categorical Outcomes
#'
#' Performs pairwise group comparisons on a categorical outcome, automatically
#' selecting chi-square test or Fisher's exact test based on whether any
#' expected cell count falls below 5.
#'
#' @param data A data frame.
#' @param outcome <[`data-masking`][dplyr::dplyr_data_masking]> Unquoted name of
#'   the categorical outcome column.
#' @param group <[`data-masking`][dplyr::dplyr_data_masking]> Unquoted name of
#'   the grouping column.
#'
#' @return A tibble with one row per group pair, containing:
#'   \describe{
#'     \item{group_1, group_2}{Group labels for the pair.}
#'     \item{n_1, n_2}{Sample sizes per group.}
#'     \item{test_used}{Either `"Chi-square Test"` or `"Fisher's Exact Test"`.}
#'     \item{p_value}{P-value from the selected test.}
#'   }
#'
#' @details
#' For each pair, a contingency table is built and chi-square is first run to
#' inspect expected counts. If any expected count is below 5, Fisher's exact
#' test is used instead. Rows with `NA` in either `outcome` or `group` are
#' dropped before analysis.
#'
#' @examples
#' set.seed(42)
#' df <- data.frame(
#'   result = sample(c("Yes", "No"), 90, replace = TRUE),
#'   grp    = rep(c("A", "B", "C"), each = 30)
#' )
#' pairwise_auto_cat_test(df, result, grp)
#'
#' @importFrom stats chisq.test fisher.test
#' @importFrom utils combn
#' @importFrom dplyr select filter
#' @importFrom purrr map_dfr
#' @importFrom rlang enquo `!!`
#' @importFrom tidyr drop_na
#' @importFrom tibble tibble
#' @export
pairwise_auto_cat_test <- function(data, outcome, group) {
  outcome <- enquo(outcome)
  group   <- enquo(group)

  df <- data |>
    select(
      outcome = !!outcome,
      group   = !!group
    ) |>
    drop_na()

  groups <- unique(df$group)

  results <- combn(groups, 2, simplify = FALSE) |>
    map_dfr(function(pair) {
      pair_df <- df |> filter(group %in% pair)

      tab      <- table(pair_df$group, pair_df$outcome)
      chi_res  <- suppressWarnings(chisq.test(tab))
      use_fisher <- any(chi_res$expected < 5)

      if (use_fisher) {
        test_res  <- fisher.test(tab)
        test_used <- "Fisher's Exact Test"
      } else {
        test_res  <- chisq.test(tab)
        test_used <- "Chi-square Test"
      }

      tibble(
        group_1   = pair[1],
        n_1       = sum(pair_df$group == pair[1]),
        group_2   = pair[2],
        n_2       = sum(pair_df$group == pair[2]),
        test_used = test_used,
        p_value   = test_res$p.value
      )
    })

  results
}
