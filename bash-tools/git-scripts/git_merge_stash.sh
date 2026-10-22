#!/usr/bin/env bash

# Git stash merge

# Author : Bobby Valenzuela
# Created : 11th June 2022
# Last Modified : 11th June 2022

# Description:
# Merge all local changes with changes from another saved stash by referncing the stash name of the saved stash. 
# This creates a new branch holding these changes.


# Usage: ./git_merge_stash.sh

# Save thine stash with unique id - epoch
stash_save_name=$(date +%s | tr -s [:space:])

git stash save "${stash_save_name}"

# Remove leading chars we don't need (xargs removes leading/trailing whitespace too)
current_branch_name=$(git branch | grep '*' | sed s:'*':: | tr -s [:space:] | xargs)

git checkout master && git pull && git checkout -b "${current_branch_name}-merged-${stash_save_name}" 

# This is name of stash to additionally apply - blank by default so  you wil be prompted. 
# Hardcode in a value if you plan to always merge with a certain stash
stash_name=""

# If blank then prompt
[[ "${stash_name}" == "" ]] && read -p "Enter the name of the stash to merge with your current changes: " stash_name

# Find thine stash index
stash_num=$(git stash list | grep $stash_name | tr -s [:alpha:] '-' | tr -s [:punct:] '-' | sed -E 's/ |\-//g')

# Thine Error handling
[[ "${stash_num}" == "" ]] && echo 'No stash found with that name' && exit 1;

echo "Found '${stash_name}'. Applying stash..."

# Apply thine stashes thereof - first apply found stash
git stash apply --index $stash_num

# Applying a second stash (our original unstaged code) - can pipe to git apply to bypass git warning of conflicting stashes 
git stash show -p 0 | git apply
