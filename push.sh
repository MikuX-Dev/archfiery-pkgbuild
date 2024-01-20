#!/usr/bin/env bash
# shellcheck disable=SC2035

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u", "-o pipefail" to make the script more robust
set -euo pipefail

# Define variables for paths
REPO_DIR="/home/builder/archfiery-repo"
X86_64_DIR="$REPO_DIR/x86_64"
OUTPUT_LARGE_DIR="/home/builder/output-large"
OUTPUT_SMALL_DIR="/home/builder/output-small"

# Move to the repository directory
cd "$REPO_DIR"

# Install Git LFS
git lfs install

# Move to the x86_64 directory and copy large packages
cd "$X86_64_DIR"
cp -r "$OUTPUT_LARGE_DIR"/* .

# Track large packages with Git LFS and echo each name
for package in *.pkg.tar.*; do
  name=$(basename "$package")
  echo "Tracking $name with Git LFS"
  git lfs track "$name"
done

# Configure Git attributes
cat >>.gitattributes <<EOF
*.zst filter=lfs diff=lfs merge=lfs -text
*.zst !text !filter !merge !diff
EOF
mv .gitattributes "$REPO_DIR/"

# Copy small packages
cp -r "$OUTPUT_SMALL_DIR"/* .

# Make the update-db.sh script executable and run it
cd "$X86_64_DIR"
chmod +x ./update-db.sh
./update-db.sh

# Configure Git user information and commit changes
cd "$REPO_DIR/"
git config --local user.email "actions@github.com"
git config --local user.name "GitHub Actions"
git add .
git commit -m "Add built packages"
git push
#
