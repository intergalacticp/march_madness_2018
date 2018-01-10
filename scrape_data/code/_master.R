#######################################################################################################################
### Purpose:  run all of dataset scraping
### Author:   BMW
#######################################################################################################################

#####################
### Load packages ###
#####################
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               httr,
               rvest,
               lubridate
)

###############################################
### Set environment variables and functions ###
###############################################
options(stringsAsFactors = F)
setwd('H:/small_ballers/march_madness_2018/scrape_data/code')
source("../input/define_parameters.R")
source("define_functions.R")

##################################
### Create datasets and export ###
##################################
source("create_datasets.R")
source("export_as_csv.R")