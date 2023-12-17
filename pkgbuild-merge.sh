#!/usr/bin/env bash

# Script name: pkgbuild-merge.sh
# Description: Rewrite outdated PKGBUILDs with the newer PKGBUILD; use this after running pkgbuild-check.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

echo "$0"
full_path=$(realpath "$0")
dir_path=${full_path%/*}

readarray -t x86_list <<<"$(find x86_64/ -type f -name PKGBUILD | awk -F / '{print $2}')"

bold4=$(tput bold setaf 4)
unfrmt=$(tput sgr0)

for x in "${x86_list[@]}"; do
  cd "${dir_path}"/x86_64/"${x}"
  if [ -f "${x}/PKGBUILD" ]; then
    if ! cmp --quiet "PKGBUILD" "${x}/PKGBUILD"; then
      echo -e "${bold4}++ A newer PKGBUILD is available:${unfrmt}  PKGBUILD for ${x} has been merged."
      mv "${x}/PKGBUILD" PKGBUILD
    fi
  fi
done
