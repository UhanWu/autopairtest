# autopairtest: Automatic Pairwise Statistical Testing for Continuous and Categorical Outcomes

Provides functions for automatic pairwise comparisons of independent or
paired groups. 'pairwise_auto_test()' compares continuous outcomes
between all pairs of independent groups, automatically selecting Welch
t-test (if both groups pass Shapiro-Wilk normality) or Wilcoxon rank-sum
test. 'pairwise_auto_cat_test()' compares categorical outcomes,
automatically selecting chi-square or Fisher's exact test based on
expected cell counts. 'pairwise_auto_paired_test()' matches continuous
observations by pair ID and automatically selects a paired t-test or
Wilcoxon signed-rank test based on normality of the within-pair
differences.

## See also

Useful links:

- <https://uhanwu.github.io/autopairtest/>

- <https://github.com/UhanWu/autopairtest>

- Report bugs at <https://github.com/UhanWu/autopairtest/issues>

## Author

**Maintainer**: Yuhan (Max) Wu <wuyuhanm@gmail.com>

Authors:

- Yuhan (Max) Wu <wuyuhanm@gmail.com>
