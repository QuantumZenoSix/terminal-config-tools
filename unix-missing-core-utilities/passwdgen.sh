#!/usr/bin/env bash

# Simple random password generator

# Author : Bobby Valenzuela
# Created : 11th June 2022
# Last Modified : 11th June 2022

# Description:
# Generates a random password using the length provided into the program.

# Usage: ./passwdgen.sh

which openssl &> /dev/null || echo -e "openssl library is required. Please install.\nExiting..." && return 1

printf "Welcome to the random password generator.\n\n"

integertest='^[0-9]+$'

# Keep trying if we don't have an integer or we have one that's > 60 digits
while [[ ! ( "$PASS_LEN" =~ $integertest ) || ( "${PASS_LEN}" -gt 60 ) ]]
do
    # Add ability to exit program
    [[ "${PASS_LEN}" = 'exit' ]] && exit 0;

    read -p "Password length (must be a digit): " PASS_LEN

    [[ "${PASS_LEN}" -gt 60 ]] && echo "Password length cannot exceed 60 characters"

done

read -p "Use special characers? (y/n) " use_special_chars

echo

for i in {1..4}
do

    # Generate rand num from 1 - 3 to determine where to start/end
    rand_offset=$(( ( $RANDOM % 3 ) + 1 ))
    end_offset=$(( ( $PASS_LEN + $rand_offset ) - 1 ))

    [[ "${use_special_chars,,}" = 'n' ]] && openssl rand -base64 48 | sed 's/[[:punct:]]/_/g' | cut -c$rand_offset-$end_offset
    [[ "${use_special_chars,,}" != 'n' ]] && openssl rand -base64 48 | cut -c$rand_offset-$end_offset

done

exit 0
