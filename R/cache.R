
CACHE <- new.env(parent = emptyenv())


get_cache_dir <- function(cache = getOption("mlr3hf.cache", FALSE)) {

  if (isFALSE(cache)) {
    return(tempdir())
  }

  if (!is.character(cache)) {
    cache <- tools::R_user_dir("mlr3hf", "cache")
  }

  if (!dir.exists(cache)) {
    dir.create(cache, recursive = TRUE)
  }

  normalizePath(cache, mustWork = FALSE)
}


initialize_cache <- function(cache_dir) {

  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  message("[mlr3hf] Cache initialized at: ", cache_dir)
}



cached <- function(fun,
                   dataset,
                   config,
                   ...,
                   cache_dir = get_cache_dir(),
                   parquet = FALSE) {


  base_path <- file.path(cache_dir, dataset, config)

  if (!dir.exists(base_path)) {
    dir.create(base_path, recursive = TRUE)
  }


  if (isTRUE(parquet)) {

    dataset_dir <- base_path

    # Check if already cached
    if (dir.exists(dataset_dir)) {

      files <- list.files(dataset_dir, recursive = TRUE, full.names = TRUE)

      if (length(files) > 0) {
        message("[mlr3hf] Using cached dataset: ", dataset_dir)
        return(dataset_dir)
      }
    }

    result <- fun(dataset = dataset,
      config  = config,
      ...,
      file_dir = dataset_dir
    )
    files <- list.files(dataset_dir, recursive = TRUE, full.names = TRUE)

    if (!dir.exists(dataset_dir) || length(files) == 0) {
      stop("Download failed or dataset directory is empty")
    }

    return(dataset_dir)
  }

  stop("[mlr3hf] Non-parquet caching not implemented yet")
}