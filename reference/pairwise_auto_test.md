# Automatic Pairwise Test for Continuous Outcomes

Performs pairwise group comparisons on a continuous outcome,
automatically selecting Welch t-test when both groups pass Shapiro-Wilk
normality (p \> 0.05) or Wilcoxon rank-sum test otherwise.

## Usage

``` r
pairwise_auto_test(data, outcome, group)
```

## Arguments

- data:

  A data frame.

- outcome:

  \<[`data-masking`](https://dplyr.tidyverse.org/reference/dplyr_data_masking.html)\>
  Unquoted name of the continuous outcome column.

- group:

  \<[`data-masking`](https://dplyr.tidyverse.org/reference/dplyr_data_masking.html)\>
  Unquoted name of the grouping column.

## Value

A tibble with one row per group pair, containing:

- group_1, group_2:

  Group labels for the pair.

- n_1, n_2:

  Sample sizes per group.

- shapiro_p_1, shapiro_p_2:

  Shapiro-Wilk p-values (NA if n \< 3 or n \> 5000).

- test_used:

  Either `"Welch t-test"` or `"Wilcoxon rank-sum"`.

- p_value:

  Two-sided p-value from the selected test.

## Details

Shapiro-Wilk is run per group on the full dataset (not just the pair).
Both groups must have a valid, significant normality p-value (\> 0.05)
for the t-test to be used; otherwise Wilcoxon is used. Rows with `NA` in
either `outcome` or `group` are dropped before analysis.

## Examples

``` r
set.seed(1)
df <- data.frame(
  value = c(rnorm(20, 5), rnorm(20, 6), rnorm(20, 5.5)),
  grp   = rep(c("A", "B", "C"), each = 20)
)
pairwise_auto_test(df, value, grp)
#> # A tibble: 3 × 8
#>   group_1   n_1 shapiro_p_1 group_2   n_2 shapiro_p_2 test_used    p_value
#>   <chr>   <int>       <dbl> <chr>   <int>       <dbl> <chr>          <dbl>
#> 1 A          20       0.419 B          20       0.313 Welch t-test 0.00712
#> 2 A          20       0.419 C          20       0.735 Welch t-test 0.109  
#> 3 B          20       0.313 C          20       0.735 Welch t-test 0.190  
```
