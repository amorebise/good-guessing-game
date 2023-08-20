#!/bin/bash
# Bash script for Number Guessing Challenge 

#echo -e "\n~~ Number Guessing Game ~~\n" 

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))

GUESS_COUNT=0
echo -e "Enter your username:"
read NAME
  USERNAME=$($PSQL "SELECT username FROM games WHERE username='$NAME'")
  if [[ -z $USERNAME ]] 
  then 
    USERNAME=$NAME
    BEST_GAME=1000
    echo $($PSQL "INSERT INTO games(username, games_played, best_game) VALUES ('$USERNAME', 1, 1000)")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    ((GAMES_PLAYED++))
    echo $($PSQL "UPDATE games SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  fi
echo -e "Guess the secret number between 1 and 1000:"
while true
do
  read GUESS
  ((GUESS_COUNT++))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
  else 
    if [[ $GUESS -lt $SECRET_NUMBER ]] 
    then
      echo -e "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo -e "It's lower than that, guess again:"
    else 
      if [[ $GUESS_COUNT -lt $BEST_GAME ]]
      then
        echo $($PSQL "UPDATE games SET best_game=$GUESS_COUNT WHERE username='$USERNAME'")
      fi
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
      exit 
    fi
  fi
done 
