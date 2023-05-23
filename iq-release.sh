#!/bin/bash

# 1. Stash all modifications in the master branch
git stash save "Temporary stash"

# 2. Sync master and release branches to the latest versions
git checkout master
git pull origin master
git checkout release
git pull origin release

# 3. Merge master into the release branch
git merge master

# 4. Get user input for the fix version and deployment cluster
read -p "Enter the current fix version (e.g., ZoomIQ-Web-${YYYYMMDD}): " fix_version
read -p "Enter the deployment cluster: " cluster

# 5. Generate a new tag name
release_date=$(date +"%Y%m%d")
tag_name="${fix_version}${cluster}1" # Starting N as 1 by default

# Check if a tag with the same name already exists, increment N if it does
existing_tag=$(git tag -l "${tag_name}")
while [ -n "${existing_tag}" ]; do
    # Extract the current N value from the tag name
    current_n=$(echo "${tag_name}" | sed -E 's/.*([0-9]+)$/\1/')
    new_n=$((current_n + 1))

    # Update the tag name
    tag_name="${fix_version}${cluster}${new_n}"
    existing_tag=$(git tag -l "${tag_name}")
done

# 6. Push the release branch and tag to the remote repository
git push origin release
git tag "${tag_name}"
git push origin "${tag_name}"

# 7. Restore modifications in the master branch
git checkout master
git stash pop
