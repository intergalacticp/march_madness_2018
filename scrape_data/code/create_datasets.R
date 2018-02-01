#######################################################################################################################
### Purpose:  compile game, player-game, team, and player datasets
### Author:   BMW
#######################################################################################################################

##############################################
### Create game and player game dataframes ###
##############################################

# Get game list
game_list <- getGamesByDateRange(start_date, end_date)
player_game_data <- data.frame()
game_data   <- data.frame()

# Iterate through game list
for (row in 18734:nrow(game_list)){
  address    <- game_list[row, "address"]
  a_team     <- game_list[row, "a_team"]
  b_team     <- game_list[row, "b_team"]
  a_flag     <- game_list[row, "a_flag"]
  b_flag     <- game_list[row, "b_flag"]
  # Get game box scores
  game_boxes <- getBoxScoreByGame(address, a_team, b_team)
  away_box   <- game_boxes[[1]] %>% mutate(game_id = row, PTS = as.numeric(PTS))
  home_box   <- game_boxes[[2]] %>% mutate(game_id = row, PTS = as.numeric(PTS))
  # Box scores have "whole team" row, so max(PTS) gets each team's point totals
  away_score <- away_box %$% max(PTS)
  home_score <- home_box %$% max(PTS)
  court      <- "B"
  date       <- game_list[row, "date"]
  # Add row with game information to game dataframe
  row        <- data.frame(game_id = row,
                           team_a  = a_team,
                           team_b  = b_team,
                           court   = court,
                           a_score = away_score,
                           b_score = home_score,
                           a_flag  = a_flag,
                           b_flag  = b_flag,
                           date    = date,
                           season  = ifelse(month(date)>=8, year(date)+1,year(date)))
  game_data <- bind_rows(game_data, row)
  
  # Remove "whole team row and add season field to box scores, then append to player_game_data
  away_box <- away_box[-nrow(away_box),] %>% mutate(season = ifelse(month(date)>=8, year(date)+1,year(date)))
  home_box <- home_box[-nrow(home_box),] %>% mutate(season = ifelse(month(date)>=8, year(date)+1,year(date)))
  
  player_game_data <- bind_rows(player_game_data, away_box, home_box)
}

# Clear workspace and save files
rm(address, game_boxes, away_box, home_box, a_team, b_team, away_score, home_score, a_flag, b_flag, court, date, row)
gc()

saveRDS(game_data, "../output/rds/game_data.RDS")
saveRDS(player_game_data, "../output/rds/player_game_data.RDS")

rm(game_data, player_game_data, game_list)
gc()

#########################################
### Create team and player dataframes ###
#########################################

# Get list of unique team names where flag == 0 (flag signifies that there is no detailed data for team)
game_data <- readRDS("../output/rds/game_data.RDS")

teams <- game_data %>% filter(a_flag == 0) %>% select(team_a) %>% rename(team = team_a)
teams <- bind_rows(teams, game_data %>% filter(b_flag == 0) %>% select(team_b) %>% rename(team = team_b)) %>% distinct()

team_data <- data.frame()

# For each team, append all rows (each a distinct season) to dataframe
for(row in 1:nrow(teams)){
  team <- teams[row, "team"]
  team_rows <- getTeamStats(team)
  team_data <- bind_rows(team_data, team_rows)
}

player_data <- data.frame()

# For each team-season, get rows for players and append to dataframe
for(row in 1:nrow(team_data)){
  team <- team_data[row, "team_name"]
  season <- team_data[row, "Season"]
  missing <- team_data[row, "missing"]
  player_rows <- data.frame()
  # Only add player data for present teams after start date year
  if(!missing & as.numeric(season) >= year(as.Date(start_date))){
    tryCatch(
      player_rows <- getPlayerStats(team, season)
      , error = function(e){team_data[row, "missing"] <- T}
    )
    player_data <- bind_rows(player_data, player_rows)
    
    
  }
}

# Save and clear dataspace
rm(teams, team, game_data, team_rows, row, season, player_rows, missing)
gc()

saveRDS(team_data, "../output/rds/team_data.RDS")
saveRDS(player_data, "../output/rds/player_data.RDS")

rm(team_data, player_data)
gc()