#!/usr/bin/env bash

# Script name: push.sh
# Description: Script for pushing *.tar.* to "$pkg_dir".
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# pkg_dir="pkg"
REMOTE_REPO="ssh://git@github.com/MikuX-Dev/archfiery-repo.git"

# Create the pkg directory if it doesn't exist
# mkdir -p "$pkg_dir"

# clone the repository
git clone $REMOTE_REPO out/

# copy package
for dir in x86_64/*/; do
  cp -r "$dir"/*.tar.* out/x86_64/ # "$pkg_dir"
done

cd out/
git config user.name "GitHub Actions Bot"
git config user.email "actions@github.com"
git add .
git commit -m "Add packages built from ${GITHUB_REF##*/}"
git push
