#!/usr/bin/env bash

# EZ-SSH

# Author : Bobby Valenzuela
# Created : 20th June 2023
# Last Modified : 20th June 2023

# Description:
# List all of the available hosts in your SSH config file and select one to connect to from numbered list.

PS3="Which system would you like to connect to?: "
COLUMNS=1
select machine in $(awk '/^\s*Host\s/ { print $2 }' ~/.ssh/config | sort)
do
        echo -e "\nSelected ${machine}. Connecting...\n"
        ssh $machine
        break
done
