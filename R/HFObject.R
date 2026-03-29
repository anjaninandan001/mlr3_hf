HFObject = R6::R6Class(
  "HFObject",

  public = list(

    initialize = function(dataset, config, target = NULL) {

      private$.dataset = checkmate::assert_string(dataset)
      private$.config  = checkmate::assert_string(config)
     

      if (!is.null(target)) {
        private$.target = checkmate::assert_string(target)
      }
    
      private$.cache_dir = get_cache_dir(
        getOption("mlr3hf.cache", FALSE)
      )

      if (!dir.exists(private$.cache_dir)) {
        dir.create(private$.cache_dir, recursive = TRUE)
      }
      if (exists("initialize_cache")) {
        initialize_cache(private$.cache_dir)
      }
    }

    
    # help = function() {
    #   utils::help(self$man, package = "mlr3hf")
    #}
  ),

  active = list(


    dataset = function(rhs) {
      #assert_ro_binding(rhs)
      if (!missing(rhs)) stop("dataset is read-only", call. = FALSE)
      private$.dataset
    },

    config = function(rhs) {
      #assert_ro_binding(rhs)
      if (!missing(rhs)) stop("config is read-only", call. = FALSE)
      private$.config
    },

    target = function(rhs) {
      if (!missing(rhs)) stop("target is read-only", call. = FALSE)
      private$.target
    },

    server = function(rhs) {
      if (!missing(rhs)) stop("server is read-only", call. = FALSE)
      private$.server
    },

    cache_dir = function(rhs) {

      if (!missing(rhs)) {
        stop("cache_dir is read-only", call. = FALSE)
      }

      if (!isFALSE(private$.cache_dir) &&
          !dir.exists(private$.cache_dir)) {

        old <- private$.cache_dir

        private$.cache_dir <- get_cache_dir(
          getOption("mlr3hf.cache", FALSE)
        )

        message(sprintf(
          "[mlr3hf] Cache directory reset: '%s' → '%s'",
          old, private$.cache_dir
        ))

        if (!dir.exists(private$.cache_dir)) {
          dir.create(private$.cache_dir, recursive = TRUE)
        }

        if (exists("initialize_cache")) {
          initialize_cache(private$.cache_dir)
        }
      }

      private$.cache_dir
    }
    # man = function(rhs) {

    #   if (!missing(rhs)) {
    #     stop("man is read-only", call. = FALSE)
    #   }

    #   sprintf(
    #     "mlr3hf::HF%s",
    #     tools::toTitleCase(self$type %||% "Object")
    #   )
    # }
  ),

  private = list(
    .dataset = NULL,
    .config = NULL,
    .target = NULL,
    .server = "https://huggingface.co/api/datasets",
    .cache_dir = NULL
 ))