#!/usr/bin/env bash

set -euo pipefail

# GitHub account
USERNAME_GIT="QuantumZenoSix"

# Directory where repositories will be cloned
DEST_DIR="./${USERNAME_GIT}-repos"

# Dependencies
for cmd in curl jq git; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Error: Required command not found: %s\n' "$cmd" >&2
        exit 1
    fi
done

# Verify GitHub SSH access
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    printf 'Warning: GitHub SSH authentication may not be configured.\n'
    printf 'Check your SSH key before continuing.\n'
fi

mkdir -p "$DEST_DIR"

page=1
cloned=0
skipped=0
failed=0

while true; do
    printf '\nFetching repository list (page %s)...\n' "$page"

    response=$(curl --fail --silent --show-error --location \
        "https://api.github.com/users/${USERNAME_GIT}/repos?type=owner&per_page=100&page=${page}")

    # Ensure the API returned an array
    if ! jq -e 'type == "array"' >/dev/null <<< "$response"; then
        printf 'Error: Unexpected response from GitHub API.\n' >&2
        exit 1
    fi

    count=$(jq 'length' <<< "$response")

    # No more repositories
    (( count == 0 )) && break

    while IFS= read -r repo; do
        name=$(jq -r '.name' <<< "$repo")
        ssh_url=$(jq -r '.ssh_url' <<< "$repo")

        # Skip private repositories, just in case
        if [[ $(jq -r '.private' <<< "$repo") != "false" ]]; then
            continue
        fi

        target="${DEST_DIR}/${name}"

        if [[ -e "$target" ]]; then
            printf 'SKIP: %s (already exists)\n' "$name"
            ((skipped+=1))
            continue
        fi

        printf 'CLONE: %s\n' "$name"

        if git clone "$ssh_url" "$target"; then
            ((cloned+=1))
        else
            printf 'FAILED: %s\n' "$name" >&2
            ((failed+=1))
        fi
    done < <(jq -c '.[]' <<< "$response")

    ((page+=1))
done

printf '\n--- Results ---\n'
printf 'Cloned:  %s\n' "$cloned"
printf 'Skipped: %s\n' "$skipped"
printf 'Failed:  %s\n' "$failed"
printf 'Location: %s\n' "$DEST_DIR"

