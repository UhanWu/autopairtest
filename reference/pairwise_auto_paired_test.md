# Automatic Pairwise Test for Paired Continuous Outcomes

Performs paired, two-sample comparisons of a continuous outcome for
every pair of measurement groups. It automatically selects the paired
t-test when the within-pair differences do not reject Shapiro-Wilk
normality (p \> 0.05), or the Wilcoxon signed-rank test otherwise.

## Usage

``` r
pairwise_auto_paired_test(data, outcome, group, pair_id)
```

## Arguments

- data:

  A data frame.

- outcome:

  \<[`data-masking`](https://dplyr.tidyverse.org/reference/dplyr_data_masking.html)\>
  Unquoted name of the continuous outcome column.

- group:

  \<[`data-masking`](https://dplyr.tidyverse.org/reference/dplyr_data_masking.html)\>
  Unquoted name of the measurement-group or condition column.

- pair_id:

  \<[`data-masking`](https://dplyr.tidyverse.org/reference/dplyr_data_masking.html)\>
  Unquoted name of the column that identifies paired observations, such
  as participant ID.

## Value

A tibble with one row per group pair, containing:

- group_1, group_2:

  Group labels for the comparison.

- n_pairs:

  Number of complete matched pairs used.

- shapiro_p_difference:

  Shapiro-Wilk p-value for the within-pair differences (`NA` when
  `n_pairs` is outside 3 through 5,000 or all differences are
  identical).

- test_used:

  Either `"Paired t-test"` or `"Wilcoxon signed-rank"`.

- p_value:

  Two-sided, unadjusted p-value from the selected test.

## Details

Each `pair_id` must have at most one non-missing observation in each
group. Rows with `NA` in `outcome`, `group`, or `pair_id` are removed
first. For each group combination, only IDs observed in both groups are
retained; IDs present in only one group do not contribute to that
comparison.

For each group pair, the function:

1.  matches observations by `pair_id`;

2.  calculates `group_1 - group_2` within each matched pair;

3.  uses the paired t-test if the Shapiro-Wilk p-value for those
    differences is available and greater than 0.05, or the Wilcoxon
    signed-rank test otherwise; and

4.  returns the selected test's two-sided, unadjusted p-value.

The paired t-test assumes that the within-pair differences are
approximately normally distributed. A Shapiro-Wilk p-value above 0.05
means normality was not rejected; it does not prove normality. No
multiple-comparison adjustment is applied. The Wilcoxon signed-rank test
additionally assumes a symmetric distribution of within-pair
differences.

## Examples

``` r
set.seed(7)
paired_df <- data.frame(
  id = rep(1:20, times = 2),
  visit = rep(c("before", "after"), each = 20),
  score = c(rnorm(20, 10, 2), rnorm(20, 12, 2))
)
pairwise_auto_paired_test(paired_df, score, visit, id)
#> # A tibble: 1 × 6
#>   group_1 group_2 n_pairs shapiro_p_difference test_used     p_value
#>   <chr>   <chr>     <int>                <dbl> <chr>           <dbl>
#> 1 before  after        20                0.111 Paired t-test  0.0692
```
