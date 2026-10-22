#! /bin/bash

# Delete git branches by prefix

# Author : Bobby Valenzuela
# Created : 11th June 2022
# Last Modified : 11th June 2022

# Description:
# Removes all branches by branch name where branch name begines with string passed in 


branches=(`git branch`)

for i in ${branches[@]}
do
    pattern="^$1"

    if [[ $i =~ $pattern ]] 
        then echo `git branch -D $i`
    fi
done
