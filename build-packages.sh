#!/usr/bin/env bash

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

bold2=$(tput bold setaf 2)
bold3=$(tput bold setaf 3)
bold4=$(tput bold setaf 4)
cleanse=$(tput sgr0)

pkg_dir="pkg"

# Create the pkg directory if it doesn't exist
mkdir -p "$pkg_dir"

for dir in x86_64/*/; do
  cd "$dir"
  NAME=${dir%*/}
  curl -sSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$NAME" -o ./PKGBUILD
  if [ -f PKGBUILD ]; then
    if cmp --silent -- "PKGBUILD" "./PKGBUILD"; then
      echo -e "${bold3}## Checking the PKGBUILD:${cleanse}  PKGBUILD for $NAME has not changed."
      makepkg -sf --noconfirm --needed --noprogressbar
    else
      echo -e "${bold4}++ Checking the PKGBUILD:${cleanse}  PKGBUILD for $NAME has changed."
      mv "./PKGBUILD" PKGBUILD
      makepkg -sf --noconfirm --needed --noprogressbar || echo "FAILED TO MAKE PACKAGE: $NAME"
    fi

    # Copy package files to the pkg directory
    cp -r *.tar.* "$pkg_dir"
  else
    echo -e "${bold2}@@ PKGBUILD not available:${cleanse} $NAME is not in the AUR. Skipping!"
  fi
  cd -
done
