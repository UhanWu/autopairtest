test_that("pairwise_auto_test returns correct columns", {
  set.seed(1)
  df <- data.frame(
    value = c(rnorm(20, 5), rnorm(20, 6), rnorm(20, 5.5)),
    grp   = rep(c("A", "B", "C"), each = 20)
  )
  res <- pairwise_auto_test(df, value, grp)

  expect_s3_class(res, "tbl_df")
  expect_named(res, c("group_1", "n_1", "shapiro_p_1",
                       "group_2", "n_2", "shapiro_p_2",
                       "test_used", "p_value"))
  expect_equal(nrow(res), 3L)  # C(3,2) = 3 pairs
})

test_that("pairwise_auto_test drops NAs", {
  set.seed(2)
  df <- data.frame(
    value = c(rnorm(20), NA, rnorm(19)),
    grp   = rep(c("A", "B"), each = 20)
  )
  res <- pairwise_auto_test(df, value, grp)
  expect_equal(res$n_1 + res$n_2, 39L)
})

test_that("pairwise_auto_test selects Wilcoxon for non-normal data", {
  set.seed(3)
  df <- data.frame(
    value = c(rexp(20), rexp(20, rate = 2)),
    grp   = rep(c("A", "B"), each = 20)
  )
  res <- pairwise_auto_test(df, value, grp)
  expect_equal(res$test_used, "Wilcoxon rank-sum")
})
