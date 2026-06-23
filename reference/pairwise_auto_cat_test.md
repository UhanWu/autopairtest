# Automatic Pairwise Test for Categorical Outcomes

Performs pairwise group comparisons on a categorical outcome,
automatically selecting chi-square test or Fisher's exact test based on
whether any expected cell count falls below 5.

## Usage

``` r
pairwise_auto_cat_test(data, outcome, group)
```

## Arguments

- data:

  A data frame.

- outcome:

  \<[`data-masking`](https://dplyr.tidyverse.org/reference/dplyr_data_masking.html)\>
  Unquoted name of the categorical outcome column.

- group:

  \<[`data-masking`](https://dplyr.tidyverse.org/reference/dplyr_data_masking.html)\>
  Unquoted name of the grouping column.

## Value

A tibble with one row per group pair, containing:

- group_1, group_2:

  Group labels for the pair.

- n_1, n_2:

  Sample sizes per group.

- test_used:

  Either `"Chi-square Test"` or `"Fisher's Exact Test"`.

- p_value:

  P-value from the selected test.

## Details

For each pair, a contingency table is built and chi-square is first run
to inspect expected counts. If any expected count is below 5, Fisher's
exact test is used instead. Rows with `NA` in either `outcome` or
`group` are dropped before analysis.

## Examples

``` r
set.seed(42)
df <- data.frame(
  result = sample(c("Yes", "No"), 90, replace = TRUE),
  grp    = rep(c("A", "B", "C"), each = 30)
)
pairwise_auto_cat_test(df, result, grp)
#> # A tibble: 3 × 6
#>   group_1   n_1 group_2   n_2 test_used       p_value
#>   <chr>   <int> <chr>   <int> <chr>             <dbl>
#> 1 A          30 B          30 Chi-square Test  0.0379
#> 2 A          30 C          30 Chi-square Test  0.438 
#> 3 B          30 C          30 Chi-square Test  0.288 
```
