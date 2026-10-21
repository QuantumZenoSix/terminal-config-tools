#!/bin/bash

# Author: Bobby Valenzuela
# Created: Feb 28th 2022

# Description:
# Downloads five jokes from a free API and stores them into a csv.
# Will append to the csv if ran multiple times

# Usage ./jokester.sh

# Add CSV Headers (if no csv)
[[ ! -e jokes.csv ]] && touch jokes.csv && chmod 777 jokes.csv && output_csv="Date,Joke\n"

# Grab five jokes
for i in {1..5}
do

    new_joke=$(curl --silent --use-ascii --location --request GET 'https://icanhazdadjoke.com/' --header 'Accept: text/plain')
    timestamp=$(date +"%b, %d %Y (%I:%M %p %Z)")
    new_record="\"$timestamp\",\"$new_joke\" \n"
    output_csv+=$new_record
done

# Add jokes into the csv
echo -en "$output_csv" >> jokes.csv

[[ -e ./jokes.csv ]] && [[ -s ./jokes.csv ]] && echo "Jokes Saved to a CSV!" || { echo "Jokes failed to save to a CSV :(" ; }