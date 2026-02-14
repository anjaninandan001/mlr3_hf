test_that("htsk creates TaskClassif", {
  task <- htsk(
    repo_id = "scikit-learn/iris",
    filename = "Iris.csv",
    target = "Species"
  )
  expect_s3_class(task, "TaskClassif")
})

test_that("error on wrong target", {
  expect_error(
    htsk("scikit-learn/iris", "Iris.csv", "WrongColumn")
  )
})

