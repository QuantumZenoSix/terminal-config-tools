#!/usr/bin/env bash


# Git Get USer Stats

# Author : Bobby Valenzuela
# Created : 10th Jan 2022
# Last Modified : 10th Jan 2022

# Description:
# Print out the number of lines changed and number of commits by user
# In the script you can set the date range and dirs you want to check.
# Prints out in month-by-month increments.



# DEFINE WHICH MONTHS/YEARS TO CHECK
# ranges=("2022-1" '2022-12' '2023-01')   # Specific months
ranges=(2022-{01..12})                    # 2022 Full year (YYYY-MM)
users=('User1' 'User2')
repos=('/home/repo1/' '/home/repo2/' )


##############################
# MAIN PROGRAM
##############################

# Create Grand total obj
declare -A grand_totals
for user in ${users[@]}
do 
    grand_totals[${user}]=0
done

range_idx=0
for range in "${ranges[@]}"
do
    range_idx=$((${range_idx}+1))
    printf "\n=== Processing ${range} ===\n"

    # Create subtotal obj
    declare -A sub_totals
    for user in ${users[@]}
    do 
        sub_totals[${user}]=0
    done


    # First lets save number of commits by user for this date range across all repos
    declare -A commit_counts

    path_just_finished=

    # Repos to check
    for path in ${repos[@]}
    do

        cd ${path}

        # First lets save number of commits by user for this repo and add then to the total commits for this date range
        for user in ${users[@]}
        do 
            commits_repo=$(git log --pretty=medium  --after "${range}-01" --before "${ranges[${range_idx}]}-01"  --author="${user}" --committer="${user}" --extended-regexp --regexp-ignore-case --no-merges | grep commit  | wc -l )
            commit_counts_current=${commit_counts["${range}-${user}"]=0}
            commit_counts["${range}-${user}"]=$(($commits_repo+$commit_counts_current))
        done


        # Find applicable files in this repo to go through
        for file in $(find ${path} -maxdepth 3 -type f -and \( -iname '*.pl' -or -iname '*.js' -or -iname '*.css' \) | grep -E '(\.pl$)|(\.js$)|(\.css$)' | sort | uniq )
        do
            # Skip invalid files
            [[ ! "${file}" =~  .pl|.js|.css || ! -e "${file}" ]] && continue

            line_counter=0

            # Create counter per user/file and initialize values
            declare -A file_usr_counter
            for user in ${users[@]}
            do 
                file_usr_counter[${user}]=0
            done

            # Get counts for this file - for each user
            for user in ${users[@]}
            do 
                current_count=$(git blame "${file}" 2>/dev/null | grep -E ${range} | grep -i "${user}" | wc -l)
                line_counter=$((${line_counter}+${current_count}))

                # Add subtotals if we have data
                if [[ ${current_count} -gt 0 ]]
                then
                    sub_totals[${user}]=$((${sub_totals[${user}]}+${current_count}))
                    file_usr_counter[${user}]=$((file_usr_counter[${user}]+${current_count}))
                fi

            done

            # Skip output if no counts to show for this file
            [[ ${line_counter} -eq 0 ]] && continue

            # Print file totals
            for user in ${users[@]}
            do 
                printf "${user}: "
                printf '%-5s' "${file_usr_counter[${user}]} |" # Add 5 spaces of padding
            done

            printf " ==> File: ${file}\n"

        done 
        # END LOOP -> FINISHED GOING THROUGH FILES FOR THIS REPO
        path_just_finished=${path}
    done
    # END LOOP -> FINISHED GOING THROUGH REPOS FOR THIS DATE RANGE

    echo "------------------------------------------------"

    # Print subtotals and add them to grandtotal
    for user in ${users[@]}
    do 
        printf "${user}: ${sub_totals[${user}]} | "
        grand_totals[${user}]=$((grand_totals[${user}]+${sub_totals[${user}]}))
    done
    printf "\t==> [LineNumber Totals]\n"

    # Get/print commit coonts for this date range
    for user in ${users[@]}
    do 
        usr_commit_count=${commit_counts["${range}-${user}"]}
        printf "${user}: ${usr_commit_count} | "
        # Add to grand total while we're here
        grand_totals["${user}-commits"]=$((${grand_totals["${user}-commits"]=0}+${usr_commit_count}))
    done
    echo -e '\t==> [Commit Totals]'
    printf "\n\n"


done
# END LOOP -> FINISHED GOING DATE RANGES

# Print grand totals
printf "=== Grand Totals ===\n"

for user in ${users[@]}
do 
    printf "${user}: ${grand_totals[${user}]} | "   # Line numbers
done

echo -e " ==> [LineNumber Totals]"

# Commits
for user in ${users[@]}
do 
    printf "${user}: ${grand_totals["${user}-commits"]}   | "
done

echo -e "\t ==> [Commit Totals]"

echo
echo
