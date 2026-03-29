

as_duckdb_backend_character <- function(data, primary_key = NULL, factors = NULL) {
  # requireNamespace(c("DBI", "duckdb", "mlr3db", "checkmate")) it requiress mlr3msc
  requireNamespace("DBI")
  requireNamespace("duckdb")
  requireNamespace("mlr3db")
  requireNamespace("checkmate")
 

  # Connect DuckDB
  con = DBI::dbConnect(duckdb::duckdb())
  on.exit({DBI::dbDisconnect(con, shutdown = TRUE)}, add = TRUE)
  checkmate::assert_string(data)
  parquet_path = file.path(data, "**", "*.parquet")

  # 1: internal view (WITH split)
  DBI::dbExecute(con, sprintf("
    CREATE OR REPLACE VIEW internal_view AS
    SELECT *,
      CASE 
        WHEN filename LIKE '%%train%%' THEN 'train'
        WHEN filename LIKE '%%test%%' THEN 'test'
        WHEN filename LIKE '%%validation%%' THEN 'validation'
        ELSE 'train'
      END AS split
    FROM parquet_scan('%s', filename=true)
  ", parquet_path))

  tbl = "internal_view"


  # 2: Add primary key

  if (is.null(primary_key)) {

    primary_key = "mlr3_row_id"

    DBI::dbExecute(con, sprintf("
      CREATE OR REPLACE VIEW internal_view_pk AS
      SELECT *, row_number() OVER () AS %s
      FROM %s
    ", primary_key, tbl))

    tbl = "internal_view_pk"
  }

  # 3: Fix BOOLEAN columns
 
  table_info = DBI::dbGetQuery(
    con,
    sprintf("PRAGMA table_info('%s')", tbl)
  )

  if (any(table_info$type == "BOOLEAN")) {

    tbl_prev = tbl
    tbl = "internal_view_recoded"

    vars_orig = table_info$name
    vars = paste0("\"", vars_orig, "\"")

    idx = table_info$type == "BOOLEAN"

    vars[idx] = paste0(
      vars[idx],
      "::VARCHAR AS \"", vars_orig[idx], "\""
    )

    query = sprintf(
      "CREATE OR REPLACE VIEW %s AS SELECT %s FROM %s",
      tbl,
      paste(vars, collapse = ", "),
      tbl_prev
    )

    DBI::dbExecute(con, query)
  }

  # 4: Create mlr3 backend

  backend = mlr3db::DataBackendDuckDB$new(
    data = con,
    table = tbl,
    primary_key = primary_key
    # strings_as_factors = factors
  )
  
  
  # 5: Factor columns

  # if (!is.null(factors) && length(factors) > 0) {
  #   backend$set_col_roles(factors, roles = "factor")
  # }

  on.exit()  # Clear on.exit to prevent disconnection when backend is returned
  return(backend)
}