#' Download a Hugging Face dataset and convert it into an mlr3 Task
#'
#' This function downloads a dataset file from the Hugging Face Hub
#' and converts it into either a `TaskClassif` or `TaskRegr`
#' object from the `mlr3` package.
#'
#' The task type is automatically determined based on the type of the
#' target column:
#' - Factor/character → Classification
#' - Numeric → Regression
#'
#' @param repo_id Character string. Hugging Face dataset repository ID
#'   (e.g. `"scikit-learn/iris"`).
#' @param filename Character string. 
#' Name of the dataset file inside the repository.
#' @param target Character string. Name of the target column.
#'
#' @return An `mlr3` Task object (`TaskClassif` or `TaskRegr`).
#'
#' @examples
#' \dontrun{
#' task <- htsk(
#'   repo_id = "scikit-learn/iris",
#'   filename = "Iris.csv",
#'   target = "Species"
#' )
#' task
#' }
#'
#' @export
htsk <- function(repo_id, filename, target) {

  # ---- 1. Input validation ----
  if (!is.character(repo_id) || length(repo_id) != 1) {
    stop("`repo_id` must be a single character string.", call. = FALSE)
  }

  if (!is.character(filename) || length(filename) != 1) {
    stop("`filename` must be a single character string.", call. = FALSE)
  }

  if (!is.character(target) || length(target) != 1) {
    stop("`target` must be a single character string.", call. = FALSE)
  }

  # ---- 2. Download dataset ----
  path <- tryCatch(
    hfhub::hub_download(
      repo_id = repo_id,
      filename = filename,
      repo_type = "dataset"
    ),
    error = function(e) {
      stop(
        "Failed to download dataset from Hugging Face Hub: ",
      e$message,
      call. = FALSE
      )
    }
  )

  # ---- 3. Detect file type ----
  ext <- tolower(tools::file_ext(path))

  # ---- 4. Read file ----
  if (ext == "csv") {
    data <- readr::read_csv(path, show_col_types = FALSE)
  } else if (ext == "json") {
    data <- jsonlite::fromJSON(path)
  } else if (ext == "parquet") {
    data <- arrow::read_parquet(path)
  } else if (ext == "rds") {
    data <- readRDS(path)
  } else {
    stop("Unsupported file type: ", ext, call. = FALSE)
  }

  data <- as.data.frame(data)

  # ---- 5. Validate target ----
  if (!(target %in% colnames(data))) {
    stop("Target column not found in dataset.", call. = FALSE)
  }

  # ---- 6. Determine task type ----
  if (is.character(data[[target]])) {
    data[[target]] <- as.factor(data[[target]])
  }

  if (is.factor(data[[target]])) {
    task_class <- mlr3::TaskClassif
  } else if (is.numeric(data[[target]])) {
    task_class <- mlr3::TaskRegr
  } else {
    stop("Target column must be numeric or factor.", call. = FALSE)
  }

  task <- task_class$new(
    id = paste0(repo_id, "_", target),
    backend = data,
    target = target
  )

  return(task)
}
