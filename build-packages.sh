#!/usr/bin/env bash

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

echo "$0"
full_path=$(realpath "$0")
dir_path=${full_path%/*}

bold2=$(tput bold setaf 2)
bold3=$(tput bold setaf 3)
bold4=$(tput bold setaf 4)
cleanse=$(tput sgr0)

readarray -t x86_list <<<"$(find x86_64/ -type f -name PKGBUILD | awk -F / '{print $2}')"

for x in "${x86_list[@]}"; do
  cd "${dir_path}"/x86_64/"${x}"
  git clone "https://aur.archlinux.org/${x}.git" &>/dev/null

  if [ -f "${x}/PKGBUILD" ]; then
    if cmp --silent -- "PKGBUILD" "${x}/PKGBUILD"; then
      echo -e "${bold3}## Checking the PKGBUILD:${cleanse}  PKGBUILD for ${x} has not changed."
    else
      echo -e "${bold4}++ Checking the PKGBUILD:${cleanse}  PKGBUILD for ${x} has changed."
      mv "${x}/PKGBUILD" PKGBUILD
      makepkg -scf || echo "FAILED TO MAKE PACKAGE: ${x}"
    fi
  else
    echo -e "${bold2}@@ PKGBUILD not available:${cleanse} ${x} is not in the AUR. Rebuilding anyway!"
    rm -rf "${dir_path}"/x86_64/"${x}"/"${x}"
    makepkg -scf || echo "FAILED TO MAKE PACKAGE: ${x}"
  fi

  rm -rf "${dir_path}"/x86_64/"${x}"/"${x}"

done
