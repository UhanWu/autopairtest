# autopairtest

An R package for automatic pairwise statistical testing across all group
combinations, with test selection based on data properties. Both
functions perform **unpaired comparisons of independent samples**.

## Data structure and independence

Each row must represent one independent observational unit, and each
unit must belong to exactly one group. The functions do not match
observations between groups. They are therefore intended for independent
groups, not paired, matched, repeated-measures, or before/after data.

With groups A, B, and C, both functions analyze A vs B, A vs C, and B vs
C separately. These comparisons reuse observations when they share a
group, so the result rows are not themselves independent. Reported
p-values are unadjusted for multiple comparisons.

## Installation

``` r

# Install from GitHub
remotes::install_github("UhanWu/autopairtest")
```

## Functions

### `pairwise_auto_test()` — Continuous outcomes

Compares a continuous outcome across every pair of independent groups.
For each pair, it uses all observations in those two groups as two
unpaired samples and automatically selects:

- **Welch two-sample t-test** if Shapiro-Wilk normality is not rejected
  in either complete group (both p \> 0.05)
- **Wilcoxon rank-sum** otherwise

Shapiro-Wilk is computed once for each complete group, not separately
for every pair. A p-value above 0.05 indicates that normality was not
rejected; it does not establish normality.

``` r

library(autopairtest)

set.seed(1)
df <- data.frame(
  value = c(rnorm(20, 5), rnorm(20, 6), rnorm(20, 5.5)),
  grp   = rep(c("A", "B", "C"), each = 20)
)

pairwise_auto_test(df, value, grp)
#> # A tibble: 3 × 8
#>   group_1    n_1 shapiro_p_1 group_2    n_2 shapiro_p_2 test_used    p_value
#>   <chr>    <int>       <dbl> <chr>    <int>       <dbl> <chr>          <dbl>
#> 1 A           20       0.715 B           20       0.550 Welch t-test  0.0126
#> 2 A           20       0.715 C           20       0.929 Welch t-test  0.482
#> 3 B           20       0.550 C           20       0.929 Welch t-test  0.0740
```

### `pairwise_auto_cat_test()` — Categorical outcomes

Compares a categorical outcome across every pair of independent groups.
For each pair, it builds a group-by-outcome contingency table and
automatically selects:

- **Chi-square test** if all expected cell counts ≥ 5
- **Fisher’s exact test** if any expected cell count \< 5

``` r

set.seed(42)
df <- data.frame(
  result = sample(c("Yes", "No"), 90, replace = TRUE),
  grp    = rep(c("A", "B", "C"), each = 30)
)

pairwise_auto_cat_test(df, result, grp)
#> # A tibble: 3 × 6
#>   group_1    n_1 group_2    n_2 test_used       p_value
#>   <chr>    <int> <chr>    <int> <chr>             <dbl>
#> 1 A           30 B           30 Chi-square Test   0.433
#> 2 A           30 C           30 Chi-square Test   0.806
#> 3 B           30 C           30 Chi-square Test   0.614
```

## Notes

- Both functions use tidy evaluation — pass column names unquoted.
- `NA` values in outcome or group are dropped via `drop_na()` before
  analysis.
- Shapiro-Wilk is only computed when 3 ≤ n ≤ 5,000; outside that range
  `shapiro_p` is `NA` and Wilcoxon is used.
- The returned p-values are raw (unadjusted); apply a multiplicity
  correction separately when appropriate.

## Function names

The existing names are retained for backward compatibility.
[`pairwise_auto_cat_test()`](https://uhanwu.github.io/autopairtest/reference/pairwise_auto_cat_test.md)
already signals categorical outcomes, while
[`pairwise_auto_test()`](https://uhanwu.github.io/autopairtest/reference/pairwise_auto_test.md)
is less specific. A future major release could consider a more explicit
name such as `pairwise_auto_cont_test()`, while keeping
[`pairwise_auto_test()`](https://uhanwu.github.io/autopairtest/reference/pairwise_auto_test.md)
as a deprecated alias. Renaming now would break existing user code and
is not necessary once the outcome type and independent-sample design are
documented clearly.
