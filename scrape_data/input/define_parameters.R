#######################################################################################################################
### Purpose:  define parameters for dataset scraping
### Author:   BMW
#######################################################################################################################

#####################################
### Set date range to scrape from ###
#####################################
start_date <- "2010-09-01"
end_date   <- "2011-05-10"

#################################################################################################
### Set exceptions for teams with weird html names; format: c("predicted-name"="actual-name") ###
#################################################################################################
exceptions <- c("bristol-university" = "bristol", 
                "tcnj" = "college-of-new-jersey",
                "uc-santa-cruz" = "california-santa-cruz",
                "lemoyne-owen" = "le-moyne-owen",
                "mit" = "massachusetts-institute-of-technology",
                "uc-merced" = "california-merced",
                "ccny" = "city-college-of-new-york",
                "viterbo-university" = "viterbo",
                "hillsdale-baptistrandall-ok" = "hillsdale-free-will-baptist",
                "florida-national-university" = "florida-national")
