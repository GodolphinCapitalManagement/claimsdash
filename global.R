library(shiny)
library(data.table)
library(reticulate)
require(highcharter)

if (Sys.info()["nodename"] == "niamh") {
  use_virtualenv(
    "/home/gsinha/admin/db/dev/Python/projects/venv", required = TRUE
  )
  print("on niamh")
  READ_DB = TRUE
} else if (Sys.info()["nodename"] == "ubuntu-4gb-nyc3-01") {
  use_virtualenv(
    "/home/gsinha/admin/devs/venv", required = TRUE
  )
  READ_DB = FALSE
}
source_python("common.py")

claims_pkl = read_pickled("data/claims.pkl")
epi_enc = claims_pkl$epi_enc
sum_df = claims_pkl$sum_df
trace = claims_pkl$trace

