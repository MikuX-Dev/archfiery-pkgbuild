#!/usr/bin/env bash

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# Define the package names
NAME=("btrfs-assistant" "snapper-gui-git" "mkinitcpio-firmware" "firmware-manager" "pikaur" "yay-bin")

# Set the workspace directory
WORKSPACE_DIR=${GITHUB_WORKSPACE:-$(pwd)}

# Create a folder for each package and download PKGBUILD
for pkg in "${NAME[@]}"; do
  git clone https://aur.archlinux.org/"$pkg".git "$WORKSPACE_DIR/$pkg"
done

# Create the "output" directory
mkdir -p "$WORKSPACE_DIR/output"

# Build and package each package
for pkg in "${NAME[@]}"; do
  cd "$WORKSPACE_DIR/$pkg" || exit 1
  makepkg -csf --noconfirm --needed --noprogressbar
  cp ./*.pkg.tar.* "$WORKSPACE_DIR/output/" # Assuming output is a folder in the same directory as this script
done

echo "Packages built and copied to the output folder."
echo "Done building packages"
