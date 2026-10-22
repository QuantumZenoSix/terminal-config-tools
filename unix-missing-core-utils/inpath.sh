#!/bin/bash

# in path

# Author : Bobby Valenzuela
# Created : 11th June 2022
# Last Modified : 11th June 2022

# Description:
# inpath--Verifies that a specified program is either valid as is or can be found in the PATH directory list

# Source: Used book "Wicked Cool Shell Scripts" as my template/basis for this scrpit


# Define Functions
in_path()
{
    # Given a command and the PATH, tries to find the command. Returns 0 if found and executable; 1 if not.
    # Note that this temporarily changes the IFS (Internal Field Separator) but restores it upon completion.

    cmd=$1	ourpath=$2	result=1

    # Change IFS so for loop will use : as delimeter
    oldIFS=$IFS IFS=":"

    for dir in $ourpath
    do
        [[ -x $dir/$cmd ]] && result=0 # Found command at this point
    done

    IFS=${oldIFS}
    #echo -n "HERES YO RESULT: $result\n"
    return $result

}

checkForCmdInPath()
{
    # Returns 1 if not found using path given
    # Returns 2 if not found in $PATH
    # Returns 0 by default if no errors - as it's just the exit value -> $?

    var=$1

    # Guard Clause
    [[ "${var}" == "" ]] && return 1

    # If command starts with "/" we're looking at a path - just check the path in that case
    if [[ "${var:0:1}" == "/" ]] ; then
        if [[ ! -x $var ]] ; then
	    return 1
        fi
    elif [[ $(in_path $var "$PATH" ) -gt 0 ]] ; then
        return 2
    fi
}

# Start Program

# Exit if num args is not equal to 1
if [[ $# -ne 1 ]] ; then
    echo "Usage: $0 command" &>2
    exit 1
fi

checkForCmdInPath "$1"
# Check exit value of the above function call
case $? in
    0 ) echo "$1 found in PATH"			;;
    1 ) echo "$1 not found or not executable"	;;
    2 ) echo "$1 not found in PATH"		;;
esac

exit 0
