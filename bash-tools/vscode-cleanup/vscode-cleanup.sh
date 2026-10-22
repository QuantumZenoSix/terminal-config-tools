#!/usr/bin/env bash

# Vscode cleanup script

# Author : Bobby Valenzuela
# Created : 26th October 2022
# Last Modified : 26th October 2022

# Description:
# Sometimes the vscode 'Remote-SSH' extention leaves loads of processes running on a remote machine as well as a folder full of data (logs,extensions, etc)
# If these processes are killed and files removed, they will just be re-added up trying to connec to the remote machine again.
# Might as well routinely clean those up to reduce number of processes running especially if we're not even connected to that machine anymore.
# [KEY TAKEAWAY] This removes your .vscode-server dir and kills any running vscode processes on a remote machine


# Usage: 
# Run this script on a remote machine
# ssh machine01 'bash -s' < vscode-cleanup

# Note: above assumes you have an automated way to SSH - in the case above using PKI but could use with password either inline or via file with something like SSHPASS.

echo "Cleaning up .vscode-server directory..."

# Check if dir exists
[ -d /home/ubuntu/.vscode-server ] && echo "vscode-server dir found."

rm -r /home/ubuntu/.vscode-server

# Verify if dir was removed
[ ! -d /home/ubuntu/.vscode-server ] && echo "vscode-server dir removed."
[ -d /home/ubuntu/.vscode-server ] && echo "vscode-server dir could not be removed."

# Stop all vscode processes
echo "Removing vscode processes..."
ps aux | grep vscode-server/bin | tr -s [:space:] | cut -d " " -f2 | xargs kill &> /dev/null

echo "Processes removed - Cleanup Completed!"

exit 0
 'bash -s' < vscode-cleanup
