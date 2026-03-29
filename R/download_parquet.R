download_parquet <- function(dataset,
                             config,
                             server= "https://huggingface.co/api/datasets",
                             file_dir = NULL,
                             api_key = NULL,
                             ...) {

  if (!requireNamespace("httr", quietly = TRUE)) stop("httr required")
  if (!requireNamespace("jsonlite", quietly = TRUE)) stop("jsonlite required")

  url <- sprintf("%s/%s/parquet", server, dataset)

  headers <- NULL
  if (!is.null(api_key)) {
    headers <- httr::add_headers(
      Authorization = paste("Bearer", api_key)
    )
  }

  res <- httr::GET(url, headers)

  if (httr::status_code(res) != 200) {
    stop("Failed to fetch parquet metadata")
  }

  desc <- jsonlite::fromJSON(
    httr::content(res, "text", encoding = "UTF-8"),
    simplifyVector = FALSE
  )

  if (!config %in% names(desc)) {
    stop("Config not found: ", config)
  }

  cfg <- desc[[config]]

  downloaded <- c()

  for (split in names(cfg)) {

    urls <- cfg[[split]]

    split_dir <- file.path(file_dir, split)
    if (!dir.exists(split_dir)) dir.create(split_dir)

    for (u in urls) {

      dest <- file.path(split_dir, basename(u))

      downloaded <- c(
        downloaded,
        get_parquet(u, file = dest)
      )
    }
  }

  return(downloaded)
}


get_parquet <- function(url, retries = 3L, file = NULL) {


  message("Downloading: ", url)

  for (retry in seq_len(retries)) {

    ok <- FALSE

    try({
      utils::download.file(url, file, mode = "wb", quiet = TRUE)
      ok <- file.exists(file)
    }, silent = TRUE)

    if (ok) {
      message("Saved: ", file)
      return(file)
    }

    if (retry < retries) {

      delay <- max(rnorm(1, mean = 3), 0)

      message(sprintf(
        "Retry %d/%d in %.2f sec",
        retry, retries, delay
      ))

      Sys.sleep(delay)
    }
  }

  stop("Failed to download: ", url)
}