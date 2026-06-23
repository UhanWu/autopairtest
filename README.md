# autopairtest

An R package for automatic pairwise statistical testing across all group combinations, with intelligent test selection based on data properties.

## Installation

```r
# Install from GitHub
remotes::install_github("YOUR_USERNAME/autopairtest")
```

## Functions

### `pairwise_auto_test()` — Continuous outcomes

Compares a continuous outcome across all group pairs. Automatically selects:
- **Welch t-test** if both groups pass Shapiro-Wilk normality (p > 0.05)
- **Wilcoxon rank-sum** otherwise

```r
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

Compares a categorical outcome across all group pairs. Automatically selects:
- **Chi-square test** if all expected cell counts ≥ 5
- **Fisher's exact test** if any expected cell count < 5

```r
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
- `NA` values in outcome or group are dropped via `drop_na()` before analysis.
- Shapiro-Wilk is only computed when 3 ≤ n ≤ 5,000; outside that range `shapiro_p` is `NA` and Wilcoxon is used.
