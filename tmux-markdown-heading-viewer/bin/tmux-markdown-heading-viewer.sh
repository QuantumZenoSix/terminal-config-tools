#!/usr/bin/env bash

# tmux-markdown-heading-viewer.sh
# A script to browse markdown files in a selected directory using fzf and display them with glow.
# Allows selecting a directory, then a markdown file, and optionally a heading within the file.

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set default options for fzf, including custom color scheme
FZF_DEFAULT_OPTS="\
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --border=rounded --info=inline"

# Initialize FILE variable
FILE=

# Check if a markdown directory is saved and not resetting
if [[ -s $CURRENT_DIR/markdown_dir.txt && "${1}" != 'reset' ]]; then

    MARKDOWN_DIR=$(cat $CURRENT_DIR/markdown_dir.txt)

else

    # Prompt user to select a markdown directory using fzf
    MARKDOWN_DIR=$(
        if command -v fd >/dev/null && command -v tree >/dev/null; then
            fd --type d --hidden --follow --exclude .git . /home/ 2>/dev/null | fzf $(printf "${FZF_DEFAULT_OPTS}") --layout=reverse --preview 'tree -C {}' --header 'Choose a folder' --preview-window=down:50%
        else
            find /home/ -mindepth 1 -type d -not -path '*/\.*' 2>/dev/null | fzf $(printf "${FZF_DEFAULT_OPTS}")  --layout=reverse --preview 'ls -la --color=always {}' --preview-window=down:50% --header 'Choose a folder'
        fi
    )

    # Save the selected directory for future use
    printf "$MARKDOWN_DIR" > $CURRENT_DIR/markdown_dir.txt

fi


# Exit if no directory was selected or saved
if [[ -z "$MARKDOWN_DIR" ]]; then
    echo "No folder saved/selected!" && exit
fi


# Function to display a markdown file section, optionally starting from a selected heading
print_md_section(){
    # Get the base filename for display
    BASE_FILE=$(basename "${FILE}")

    # Count the number of headings in the file
    HEADING_COUNT=$(grep -E '^\s{0,3}#+' "$FILE" | wc -l)

    # Escape spaces in filename (though not used in the current code)
    FILENAME_ESC="$(printf $FILE | sed 's/\s/\ /g')"

    if [ "$HEADING_COUNT" -gt 0 ]; then
        # If there are headings, prompt user to choose one
        # Create message for heading selection
        MSG="Choose a heading (File: ${BASE_FILE})"
        HEADING="$(grep -E '^\s{0,3}#+' "${FILE//\ / }" | fzf $(printf "${FZF_DEFAULT_OPTS}") --layout=reverse -m --preview "grep -A 100 {} \"${FILE//\ / }\" " --preview-window down:50% --header "${MSG}")"
        HEADING="$(echo "${HEADING}" | sed -E 's:\r::' | sed -E 's:\s+$::')"	# Trim trailing newlines and spaces;	
        # awk -v h="$HEADING" 'found || $0 == h {found=1; print}' "$FILE" | glow -s dark -p
        awk -v h="$HEADING" 'found || $0 == h || $0 ~ "^[[:space:]]*" h ".*$" {found=1; print}' "$FILE" | glow -s dark -p
    else
        # If no headings, display the entire file
        glow -s dark -p "$FILE"
    fi

}

BASE_DIR=$(basename "${MARKDOWN_DIR}")
MSG="Choose a file (Folder: ${BASE_DIR})"
if command -v fd >/dev/null; then
    FILE="$(fd -H --type file -e md -e markdown . ${MARKDOWN_DIR} | fzf $(printf "${FZF_DEFAULT_OPTS}")   --layout=reverse --header "${MSG}" --preview-window down:60% --preview 'glow -p --width=80 {} ' )"
else
    FILE="$(find $MARKDOWN_DIR -type f \( -iname "*.md" -o -iname "*.markdown" \) | fzf $(printf "${FZF_DEFAULT_OPTS}")   --header "${MSG}" )"
fi


if [[ ! -z "$FILE" ]]; then
    print_md_section
fi


