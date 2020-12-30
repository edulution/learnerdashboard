library(dplyr)
library(shiny)
library(shinyFeedback)
library(shinythemes)
library(shinyWidgets)
library(shinycssloaders)
library(ggplot2)
library(config)
library(dbplyr)
library(DT)
library(pool)
library(RPostgres)
library(lubridate)

# fetch config vars for kolibri and baseline testing
bl_config <- config::get("baseline")

# create database connection pool objects
bl_pool <- dbPool(
  drv = RPostgres::Postgres(),
  dbname = bl_config$database,
  host = bl_config$server,
  user = bl_config$uid,
  password = bl_config$pwd,
  port = bl_config$port
)

usernames <- bl_pool %>%
  tbl("users") %>%
  pull("username")

# Colors for progress bars and content items in stacked bars
# content types - document , exercise, video
content_colors <- c("#0077CC","#26B7B7","#4C4CAE")
prog_bar_color <- "#1AA14D"

# Intervals and Colors for test scores
test_score_interval <- c(0.25,0.50,0.69,0.84)
test_score_colors <- c('#FF412A','#EC9090','#F5C216','#99CC33','#00B050')

# options for spinner
options(spinner.color.background = "white")
options(spinner.type = 2)
options(spinner.color = "green")