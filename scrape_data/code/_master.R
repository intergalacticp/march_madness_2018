if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr,
               httr,
               rvest,
               lubridate
)

options(stringsAsFactors = F)


source("define_functions.R")
source("define_parameters.R")
source("create_game_datasets.R")
