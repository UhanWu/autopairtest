test_that("pairwise_auto_paired_test returns every group pair", {
  set.seed(10)
  df <- data.frame(
    id = rep(1:30, times = 3),
    visit = rep(c("A", "B", "C"), each = 30),
    value = c(rnorm(30), rnorm(30, 1), rnorm(30, 2))
  )

  res <- pairwise_auto_paired_test(df, value, visit, id)

  expect_s3_class(res, "tbl_df")
  expect_named(res, c(
    "group_1", "group_2", "n_pairs", "shapiro_p_difference",
    "test_used", "p_value"
  ))
  expect_equal(nrow(res), 3L)
  expect_equal(res$n_pairs, rep(30L, 3))
})

test_that("pairwise_auto_paired_test selects a paired t-test", {
  set.seed(11)
  baseline <- rnorm(40)
  differences <- rnorm(40, 1, 0.3)
  df <- data.frame(
    id = rep(1:40, times = 2),
    visit = rep(c("before", "after"), each = 40),
    value = c(baseline, baseline + differences)
  )

  res <- pairwise_auto_paired_test(df, value, visit, id)
  expect_equal(res$test_used, "Paired t-test")
})

test_that("pairwise_auto_paired_test selects Wilcoxon for non-normal differences", {
  baseline <- seq_len(40)
  differences <- c(rep(0, 39), 10)
  df <- data.frame(
    id = rep(1:40, times = 2),
    visit = rep(c("before", "after"), each = 40),
    value = c(baseline, baseline + differences)
  )

  res <- pairwise_auto_paired_test(df, value, visit, id)
  expect_equal(res$test_used, "Wilcoxon signed-rank")
})

test_that("pairwise_auto_paired_test matches IDs and drops incomplete pairs", {
  df <- data.frame(
    id = c(1:5, 1:4),
    visit = c(rep("A", 5), rep("B", 4)),
    value = c(2, 3, 5, 8, 13, 1, 2, 4, 7)
  )

  res <- pairwise_auto_paired_test(df, value, visit, id)
  expect_equal(res$n_pairs, 4L)
})

test_that("pairwise_auto_paired_test rejects duplicate pair/group rows", {
  df <- data.frame(
    id = c(1, 1, 1, 2, 2),
    visit = c("A", "A", "B", "A", "B"),
    value = 1:5
  )

  expect_error(
    pairwise_auto_paired_test(df, value, visit, id),
    "at most one observation"
  )
})
