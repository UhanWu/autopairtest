# Automatic Pairwise Test for Categorical Outcomes

Performs unpaired, two-sample comparisons of a categorical outcome for
every pair of groups. It automatically selects the chi-square test or
Fisher's exact test based on whether any expected cell count falls below
5.

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

This function is for **independent samples**: each row represents one
independent observational unit, and each unit belongs to exactly one
group. It does not pair or match rows across groups and is not
appropriate for repeated measures, matched samples, or paired
categorical outcomes.

After rows with `NA` in either `outcome` or `group` are removed, all
unique two-group combinations are generated. For each combination, the
function:

1.  uses the observations from the two groups as independent samples;

2.  builds a contingency table of group by outcome category;

3.  obtains the chi-square expected counts and uses Fisher's exact test
    if any expected count is below 5, or the chi-square test otherwise;
    and

4.  returns the selected test's unadjusted p-value.

Comparisons can share a group, so the rows of the returned result are
not themselves statistically independent. No adjustment for multiple
comparisons is applied.

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
