#######################################################################################################################
### Purpose:  output game, player-game, team, and player datasets as csvs
### Author:   BMW
#######################################################################################################################

# Read in finished dataframes
game_data         <- readRDS("../output/rds/game_data.RDS")
player_game_data  <- readRDS("../output/rds/player_game_data.RDS")
team_data         <- readRDS("../output/rds/team_data.RDS")
player_data       <- readRDS("../output/rds/player_data.RDS")

# Save using write.csv
write.csv(game_data, file = "../output/csv/game_data.csv")
write.csv(player_game_data, file = "../output/csv/player_game_data.csv")
write.csv(team_data, file = "../output/csv/team_data.csv")
write.csv(player_data, file = "../output/csv/player_data.csv")