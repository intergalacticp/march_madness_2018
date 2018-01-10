#######################################################################################################################
### Purpose:  define functions for dataset scraping
### Author:   BMW
#######################################################################################################################

#################################################################
### Paste function, creates %p% pipe to substitute for paste0 ###
#################################################################

`%p%` <- function(x, y) paste0(x, y)

################################################################
### Given date, scrape sports-reference box scores for games ###
################################################################

getGamesByDate <- function(year,month,day) {
  # Query to get boxscore page
  url_string <- paste0("https://www.sports-reference.com/cbb/boxscores/?month=",
                        as.character(month),
                        "&year=",
                        as.character(year),
                        "&day=",
                        as.character(day))
  parse_doc <- read_html(url_string)
  # All a under table.teams are either detailed game links or team links
  games <- html_nodes(parse_doc,"table.teams") %>%
    html_nodes("a")
  # Get both text and attributes for scraping
  game_names <- data.frame(names = games %>% html_text(), links = games %>% html_attrs() %>% as.character())
  # Create flag for text without links; these teams have no detailed pages
  # Create temp variable; this is the approximation of the name used by sports-reference to construct html later
  game_names %<>% mutate(flag = ifelse(links != "character(0)", 0, 1), temp = ifelse(links != "character(0)", 
                                        # For linked teams, use the school name in the link
                                        gsub("/.html","",gsub("/cbb/schools/","",gsub("[0-9]","",links))),
                                        # For unlinked teams, use regex to get alphanumeric, substitute spaces
                                        # with dashes, set to lowercase
                                        tolower(gsub("\\s", "-",gsub("  "," ",gsub("[^a-zA-Z0-9 \\-]", "",names))))))
  # Links to the detailed game page are named "Final", we want their link, otherwise take the temp field
  game_names %<>% mutate(names = ifelse(names == "Final", links, temp)) %>% select(names,flag,flag)
  # If the name is in the exceptions list, the html tables don't use the linked team name. Set in define_parameters.R
  game_names %<>% mutate(names = ifelse(names %in% names(exceptions), exceptions[names], names))
  # Every three rows are together, so spread these each into a column
  addresses <- game_names[seq(2,nrow(game_names),3),1]
  a_teams   <- game_names[seq(1,nrow(game_names),3),1]
  b_teams   <- game_names[seq(3,nrow(game_names),3),1]
  a_flags   <- game_names[seq(1,nrow(game_names),3),2]
  b_flags   <- game_names[seq(3,nrow(game_names),3),2]
  # Make it a dataframe, add date
  games <- data.frame(address = addresses, a_team = a_teams, b_team = b_teams, a_flag = a_flags, b_flag = b_flags)
  games <- games %>% mutate(date = as.Date(paste0(year, "-", month, "-", day)))
  return(games)
}

##########################################################
### Calls get game by date on each date within a range ###
##########################################################

getGamesByDateRange <- function(startDate, endDate) {
  # Get sequence of dates between start and end
  dates <- seq(as.Date(startDate),
               as.Date(endDate), "days")
  games <- data.frame(address = character())
  # Iterate through sequence and bind output of getGamesByDate to output dataframe
  for(date in dates){
    date <- as.Date(date, origin="1970-01-01")
    games <- rbind(games,getGamesByDate(year(date),month(date),day(date)))
  }
  return(games)
}

#######################################################################
### Given an address and the html names of teams, return box scores ###
#######################################################################

getBoxScoreByGame <- function(address, a_team, b_team) {
  url_string <- paste0("https://www.sports-reference.com",address)
  parse_doc <- read_html(url_string)
  away_team <- a_team
  home_team <- b_team
  # Call getTeamBox given the page document and html team name
  away_box  <- getTeamBox(parse_doc, away_team)
  home_box  <- getTeamBox(parse_doc, home_team)
  boxes     <- list(away_box, home_box)
  return(boxes)
}

#############################################################
### Given a document and html team name, return box score ###
#############################################################

getTeamBox <- function(parse_doc, team_name){
  # Box scores are located at table#box-score-basic-team-name
  team_box  <- html_nodes(parse_doc, "table#box-score-basic-" %p% team_name) %>% html_table()
  # html_table produces a list, we just want the table
  team_box  <- team_box[[1]]
  # the first row read by html_table is the column names
  colnames(team_box) <- team_box[1,]
  # Get rid of intermediate rows with column names, add team_name column
  team_box  <- team_box[c(-1,-7),] %>% mutate(team_name = team_name)
  return(team_box)
}

############################################################
### Given a team name, return team detailed annual stats ###
############################################################

getTeamStats <- function(team_name){
  url_string  <- paste0("https://www.sports-reference.com/cbb/schools/",team_name, "/")
  parse_doc   <- read_html(url_string)
  # Team stats are literally under table#team-name
  year_table  <- html_nodes(parse_doc, "table#" %p% team_name) %>% html_table()
  # html_table produces a list, we just want the table
  year_table  <- year_table[[1]]
  # Both points for and against are read in as "PT" by html_table
  colnames(year_table)[c(9,10)] <- c("PFPG", "PAPG")
  # Every 21st row repeats the column names, get rid of these
  if(nrow(year_table)>=22){
    year_table <- year_table[-seq(21,nrow(year_table),21),]
  }
  # Seasons with nm in the name don't have detailed pages
  year_table %<>% mutate(team_name = team_name,
                         missing = grepl("nm", Season),
                         # season comes in as something like 2007-08, pick the later year, then fix 1999-00 case
                         Season = ifelse(substr(Season,6,7)=="00",as.character(as.numeric(substr(Season,1,2))+1),substr(Season,1,2)) %p% substr(Season,6,7)
                         )
  # Make sure everything comes in as character to prevent row_bind issues later
  year_table %<>% mutate_at(c("Rk","W","L","W-L%","SRS","SOS","PFPG","PAPG","AP Pre","AP High","AP Final", "NCAA Tournament"), as.character)
  return(year_table)
}

##############################################################
### Given season and team_name, return player roster table ###
##############################################################

getPlayerStats <- function(team_name, season){
  url_string  <- paste0("https://www.sports-reference.com/cbb/schools/",team_name, "/", season, ".html")
  parse_doc   <- read_html(url_string)
  # Team roster always under table#roster
  player_table  <- html_nodes(parse_doc, "table#roster") %>% html_table()
  # html_table produces a list, we just want the table
  player_table  <- player_table[[1]]
  # Add team name and season
  player_table %<>% mutate(team_name = team_name, season = season)
  # Make sure everything comes in as character to prevent row_bind issues later
  player_table %<>% mutate_at(c("Pos","Class"), as.character)
  return(player_table)
}


