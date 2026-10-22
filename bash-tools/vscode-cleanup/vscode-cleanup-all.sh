#!/usr/bin/env bash

# Vscode cleanup script controller

# Author : Bobby Valenzuela
# Created : 26th October 2022
# Last Modified : 26th October 2022

# Description:
# Used to run vscode-cleanup.sh on multiple remote machines in succession

# Usage: 
# ./vscode-cleanup-all

# Note: below assumes you've saved vscode-cleanup script in vscode-cleanup without ".sh" extension

echo "Running on Machine01..."
ssh machine01 'bash -s' < /usr/local/bin/vscode-cleanup
echo ""

echo "Running on Machine02..."
ssh machine02 'bash -s' < /usr/local/bin/vscode-cleanup
echo ""

echo "Running on Machine03..."
ssh machine03 'bash -s' < /usr/local/bin/vscode-cleanup
echo ""

echo "Running on Machine04..."
ssh machine04 'bash -s' < /usr/local/bin/vscode-cleanup
echo ""
