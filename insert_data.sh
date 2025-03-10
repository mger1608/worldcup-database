#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "CREATE TABLE IF NOT EXISTS teams (
  team_id SERIAL PRIMARY KEY,
  name VARCHAR UNIQUE NOT NULL
);"

$PSQL "CREATE TABLE IF NOT EXISTS games (
  game_id SERIAL PRIMARY KEY,
  year INT NOT NULL,
  round VARCHAR NOT NULL,
  winner_id INT NOT NULL,
  opponent_id INT NOT NULL,
  winner_goals INT NOT NULL,
  opponent_goals INT NOT NULL,
  FOREIGN KEY (winner_id) REFERENCES teams(team_id),
  FOREIGN KEY (opponent_id) REFERENCES teams(team_id)
);"

# Skip the header row and read the CSV file line by line 
tail -n +2 games.csv | while IFS=, read -r year round winner opponent winner_goals opponent_goals; do
  # insert winnder team if it doesn't exit
  WINNER_ID=$($PSQL "SELECT  team_id FROM teams WHERE name='$winner'")
  if [[ -z $WINNER_ID ]]; then
    $PSQL "INSERT INTO teams(name) VALUES('$winner')"
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  fi

  # Insert opponent team if it doesn't exist
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  if [[ -z $OPPONENT_ID ]]; then
    $PSQL "INSERT INTO teams(name) VALUES ('$opponent')"
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  fi

  # Debug statements to print variable values
  echo "Year: $year, Round: $round, Winner ID: $WINNER_ID, Opponent ID: $OPPONENT_ID, Winner Goals: $winner_goals, Opponent Goals: $opponent_goals"
  
  # Insert game data with the retrieved team IDs
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
         VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"

done
