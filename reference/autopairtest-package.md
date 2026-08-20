# autopairtest: Automatic Pairwise Statistical Testing for Continuous and Categorical Outcomes

Provides two functions for automatic, unpaired pairwise comparisons of
independent groups. 'pairwise_auto_test()' compares continuous outcomes
between all pairs of groups, automatically selecting Welch t-test (if
both groups pass Shapiro-Wilk normality) or Wilcoxon rank-sum test.
'pairwise_auto_cat_test()' compares categorical outcomes, automatically
selecting chi-square or Fisher's exact test based on expected cell
counts.

## See also

Useful links:

- <https://uhanwu.github.io/autopairtest/>

## Author

**Maintainer**: Yuhan (Max) Wu <wuyuhanm@gmail.com>

Authors:

- Yuhan (Max) Wu <wuyuhanm@gmail.com>
