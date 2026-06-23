test_that("pairwise_auto_cat_test returns correct columns", {
  set.seed(42)
  df <- data.frame(
    result = sample(c("Yes", "No"), 90, replace = TRUE),
    grp    = rep(c("A", "B", "C"), each = 30)
  )
  res <- pairwise_auto_cat_test(df, result, grp)

  expect_s3_class(res, "tbl_df")
  expect_named(res, c("group_1", "n_1", "group_2", "n_2", "test_used", "p_value"))
  expect_equal(nrow(res), 3L)
})

test_that("pairwise_auto_cat_test uses Fisher for small expected counts", {
  df <- data.frame(
    result = c("Yes", "No", "No", "No", "No", "No"),
    grp    = c("A",   "A",  "B",  "B",  "B",  "B")
  )
  res <- pairwise_auto_cat_test(df, result, grp)
  expect_equal(res$test_used, "Fisher's Exact Test")
})

test_that("pairwise_auto_cat_test drops NAs", {
  df <- data.frame(
    result = c("Yes", "No", NA, "Yes", "No", "Yes"),
    grp    = c("A",   "A", "A",  "B",  "B",  "B")
  )
  res <- pairwise_auto_cat_test(df, result, grp)
  expect_equal(res$n_1 + res$n_2, 5L)
})
