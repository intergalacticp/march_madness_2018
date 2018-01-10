`%p%` <- function(x, y) paste0(x, y)

getGamesByDate <- function(year,month,day) {
  url_string <- paste0("https://www.sports-reference.com/cbb/boxscores/?month=",
                        as.character(month),
                        "&year=",
                        as.character(year),
                        "&day=",
                        as.character(day))
  parse_doc <- read_html(url_string)
  games <- html_nodes(parse_doc,"table.teams") %>%
    html_nodes("a")
  game_names <- data.frame(names = games %>% html_text(), links = games %>% html_attrs() %>% as.character())
  game_names %<>% mutate(flag = ifelse(links != "character(0)", 0, 1), temp = ifelse(links != "character(0)", 
                                        gsub("/.html","",gsub("/cbb/schools/","",gsub("[0-9]","",links))),
                                        tolower(gsub("\\s", "-",gsub("  "," ",gsub("[^a-zA-Z0-9 \\-]", "",names))))))
  game_names %<>% mutate(names = ifelse(names == "Final", links, temp)) %>% select(names,flag,flag)
  game_names %<>% mutate(names = ifelse(names %in% names(exceptions), exceptions[names], names))
  addresses <- game_names[seq(2,nrow(game_names),3),1]
  a_teams   <- game_names[seq(1,nrow(game_names),3),1]
  b_teams   <- game_names[seq(3,nrow(game_names),3),1]
  a_flags   <- game_names[seq(1,nrow(game_names),3),2]
  b_flags   <- game_names[seq(3,nrow(game_names),3),2]
  games <- data.frame(address = addresses, a_team = a_teams, b_team = b_teams, a_flag = a_flags, b_flag = b_flags)
  games <- games %>% mutate(date = as.Date(paste0(year, "-", month, "-", day)))
  return(games)
}

getGamesByDateRange <- function(startDate, endDate) {
  dates <- seq(as.Date(startDate),
               as.Date(endDate), "days")
  games <- data.frame(address = character())
  for(date in dates){
    date <- as.Date(date, origin="1970-01-01")
    games <- rbind(games,getGamesByDate(year(date),month(date),day(date)))
  }
  return(games)
}

getBoxScoreByGame <- function(address, a_team, b_team) {
  url_string <- paste0("https://www.sports-reference.com",address)
  parse_doc <- read_html(url_string)
  away_team <- a_team
  home_team <- b_team
  away_box  <- getTeamBox(parse_doc, away_team)
  home_box  <- getTeamBox(parse_doc, home_team)
  boxes     <- list(away_box, home_box)
  return(boxes)
}

getTeamBox <- function(parse_doc, team_name){
  team_box  <- html_nodes(parse_doc, "table#box-score-basic-" %p% team_name) %>% html_table()
  team_box  <- team_box[[1]]
  colnames(team_box) <- team_box[1,]
  team_box  <- team_box[c(-1,-7),] %>% mutate(team_name = team_name)
  return(team_box)
}

getTeamStats <- function(team_name){
  url_string  <- paste0("https://www.sports-reference.com/cbb/schools/",team_name, "/")
  parse_doc   <- read_html(url_string)
  year_table  <- html_nodes(parse_doc, "table#" %p% team_name) %>% html_table()
  year_table  <- year_table[[1]]
  colnames(year_table)[c(9,10)] <- c("PFPG", "PAPG")
  year_table %<>% mutate(teamname = team_name)
  return(year_table)
}

getPlayerStats <- function(team_name, season){
  url_string  <- paste0("https://www.sports-reference.com/cbb/schools/",team_name, "/", season, ".html")
  parse_doc   <- read_html(url_string)
  player_table  <- html_nodes(parse_doc, "table#roster") %>% html_table()
  player_table  <- player_table[[1]]
  player_table %<>% mutate(team_name = team_name, season = season)
  return(player_table)
}


