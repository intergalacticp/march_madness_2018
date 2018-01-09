getGamesByDate <- function(year,month,day) {
  url_string <- paste0("https://www.sports-reference.com/cbb/boxscores/?month=",
                        as.character(month),
                        "&year=",
                        as.character(year),
                        "&day=",
                        as.character(day))
  parse_doc <- read_html(url_string)
  games <- html_nodes(parse_doc,"td.gamelink") %>%
    html_children() %>%
    html_attrs()
  tempgames <- data.frame(address = character())
  games <- data.frame(address = unlist(games))
  return(rbind(games,tempgames))
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

getBoxScoreByGame <- function(address) {
  url_string <- paste0("https://www.basketball-reference.com",address)
  parse_doc <- read_html(url_string)
  teams <- html_nodes(parse_doc, "a[itemprop='name']") %>% html_text()
  away_team <- tolower(gsub(" ", "-",teams[[1]]))
  home_team <- tolower(gsub(" ", "-",teams[[2]]))
  away_box  <- getTeamBox(parse_doc, away_team)
  home_box  <- getTeamBox(parse_doc, home_team)
}

getTeamBox <- function(parse_doc, team_name){
  team_box  <- html_nodes(parse_doc, "table#box-score-basic-" %p% team_name) %>% html_table()
  team_box  <- team_box[[1]]
  colnames(team_box) <- team_box[1,]
  team_box  <- team_box[c(-1,-7),]
  return(team_box)
}

getPossessionByPossessionInfo <- function(address) {
  url_string <- paste0("https://www.basketball-reference.com",address)
  parse_doc <- read_html(url_string)
  players <- html_nodes(parse_doc, "div.overthrow.table_container") %>%
    html_nodes("tbody tr a") %>%
    html_text()
  players_df <- data.frame(name = character(),playing = logical(),team = character())
  players_list <- list()
  starters <- T
  counter <- 1
  team <- "H"
  for(player in players){
    if(player %in% players_list & !starters) {
      starters <- T
      counter <- 1
      team <- "A"
    }
    if(!player %in% players_list){
      players_list[[length(players_list)+1]] <- player
      temp_df <- data.frame(name = player, playing = starters, team = team)
      players_df <- rbind(players_df,temp_df)
      counter <- counter + 1
    }
    if(counter==6){
      starters <- F
    }
  }
  pbp_string <- paste0("https://www.basketball-reference.com",gsub("/boxscores/","/boxscores/pbp/",address))
  parse_doc <- read_html(pbp_string)
  plays <- html_nodes(parse_doc, "div.overthrow.table_container") %>%
    html_nodes("tr:not(.thead)") %>% 
    html_text()
}


temp <- getGamesByDateRange("2016-10-15","2016-11-15")

address <- as.character(temp[3,])
