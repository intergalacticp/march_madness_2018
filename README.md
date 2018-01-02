# march_madness_2018

Outline of planned structure:

## 1_collect_format_data
This folder's scripts scrape/aggregate/format data for use in later scripts.

-code (scripts)
-raw (all raw data inputs go here)
-intermediate (any datasets created before output to next level)
-output (datasets used by later sections of structure)

## 2_parameterize
This folder's scripts take input data and create parameterized outputs for use in the neural network.

-code (scripts)
-intermediate (any datasets created before output to next level)
-output (datasets used by neural network)

## 3_neural_network
This folder takes game data from 1 and team parameters from 2 as inputs to train a neural network for predicting the outcome of a game

I have no idea how to organize this yet.

## 4_simulation
This folder uses a tournament field and a trained neural network to repeatedly simulate tournaments, producing the expected point totals for each team.
