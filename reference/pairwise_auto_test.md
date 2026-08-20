# Automatic Pairwise Test for Continuous Outcomes

Performs unpaired, two-sample comparisons of a continuous outcome for
every pair of groups. It automatically selects Welch's t-test when
neither group's Shapiro-Wilk test rejects normality (p \> 0.05), or the
Wilcoxon rank-sum test otherwise.

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

This function is for **independent samples**: each row represents one
independent observational unit, and each unit belongs to exactly one
group. It does not pair or match rows across groups and is not
appropriate for repeated measures, before/after data, or other paired
observations.

After rows with `NA` in either `outcome` or `group` are removed, all
unique two-group combinations are generated. For each combination, the
function:

1.  uses the observations from the two groups as independent samples;

2.  looks up the Shapiro-Wilk p-value computed once on each complete
    group;

3.  uses Welch's two-sample t-test if both p-values are available and
    greater than 0.05, or the two-sample Wilcoxon rank-sum test
    otherwise; and

4.  returns the selected test's two-sided, unadjusted p-value.

Shapiro-Wilk is only evaluated for group sizes from 3 through 5,000. A
p-value greater than 0.05 means normality was not rejected; it does not
prove that the data are normally distributed. Comparisons can share a
group, so the rows of the returned result are not themselves
statistically independent. No adjustment for multiple comparisons is
applied.

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
