#!/usr/bin/env bash

# Git stash apply by name

# Author : Bobby Valenzuela
# Created : 11th June 2022
# Last Modified : 11th June 2022

# Description:
# Apply a stash by the stash name 

# Usage: gitapply mysavedstash


stash_name="${1}"
[[ "${stash_name}" == "" ]] && read -p "Enter the name of your stash: " stash_name

# get stash index
stash_num=$(git stash list | grep $stash_name | tr -s [:alpha:] '-' | tr -s [:punct:] '-' | sed -E 's/ |\-//g')

# Error handling
[[ "${stash_num}" == "" ]] && echo 'No stash found with that name' && exit 1;

echo "Found '${stash_name}'. Applying stash..."

# apply 
git stash apply --index $stash_num
