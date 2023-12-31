#!/usr/bin/env bash

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# chown user
if [ -d "/github" ]; then
  sudo chown -R builder:builder /github/workspace /github/home
fi

WORKSPACE_DIR=${GITHUB_WORKSPACE:-$(pwd)}

# Create the "output" directory
mkdir "$WORKSPACE_DIR/output"

packages=("btrfs-assistant" "snapper-gui-git" "mkinitcpio-firmware" "firmware-manager" "pikaur" "yay-bin") # Add your package names here

# Loop through the packages, clone, build, and copy
for package in "${packages[@]}"; do
  git clone "https://aur.archlinux.org/$package.git"
  cd "$package" || exit
  makepkg -csf --noconfirm --needed --noprogressbar
  cp -r ./*.pkg.* "$WORKSPACE_DIR"/output # Replace /path/to/output/directory with the actual path
  cd ..
done

echo "Packages built and copied to the output folder."
echo "Done building packages"
