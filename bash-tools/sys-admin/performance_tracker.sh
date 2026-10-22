#!/bin/bash

# Vscode cleanup script controller

# Author : Bobby Valenzuela
# Created : 26th October 2022
# Last Modified : 26th October 2022

# Description:
# Used to get general stats about a machine - very crude draft as of now...


date >> performance.log

ping -c 1 google.com &> /dev/null
if [ "$?" -eq 0 ]; then
  echo "Internet: Connected" >> performance.log
else
  echo "Internet: Disconnected" >> performance.log
fi

echo "RAM Usages :" >> performance.log
free -h | grep "Mem" >> performance.log

echo "Swap Usages :" >> performance.log
free -h | grep "Swap" >> performance.log

echo "Disk Usages :" >> performance.log
df -h >> performance.log
