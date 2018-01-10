game_list <- getGamesByDateRange(start_date, end_date)
player_data <- data.frame()
game_data   <- data.frame()

for (row in 1:nrow(game_list)){
  address    <- game_list[row, "address"]
  a_team     <- game_list[row, "a_team"]
  b_team     <- game_list[row, "b_team"]
  a_flag     <- game_list[row, "a_flag"]
  b_flag     <- game_list[row, "b_flag"]
  game_boxes <- getBoxScoreByGame(address, a_team, b_team)
  away_box   <- game_boxes[[1]] %>% mutate(game_id = row, PTS = as.numeric(PTS))
  home_box   <- game_boxes[[2]] %>% mutate(game_id = row, PTS = as.numeric(PTS))
  away_score <- away_box %$% max(PTS)
  home_score <- home_box %$% max(PTS)
  court      <- "B"
  date       <- game_list[row, "date"]
  row        <- data.frame(game_id = row,
                           team_a  = a_team,
                           team_b  = b_team,
                           court   = court,
                           a_score = away_score,
                           b_score = home_score,
                           a_flag  = a_flag,
                           b_flag  = b_flag)
  game_data <- bind_rows(game_data, row)
  
  away_box <- away_box[-nrow(away_box),]
  home_box <- home_box[-nrow(home_box),]
  
  player_data <- bind_rows(player_data, away_box, home_box)
}

rm(address, game_boxes, away_box, home_box, away_team, home_team, away_score, home_score, court, date, row)
gc()

