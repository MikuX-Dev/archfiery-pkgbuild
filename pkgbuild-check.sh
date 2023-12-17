#!/usr/bin/env bash

# Script name: pkgbuild-check.sh
# Description: Download PKGBUILDs and check if anything has changed.
# Dependencies: git, paru
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

full_path=$(realpath "$0")
dir_path=${full_path%/*}

readarray -t x86_list <<<"$(find x86_64/ -type f -name PKGBUILD | awk -F / '{print $2}')"

bold2=$(tput bold setaf 2)
bold3=$(tput bold setaf 3)
bold4=$(tput bold setaf 4)
cleanse=$(tput sgr0)

help() {
  printf '%s' "
${bold2}Usage:${cleanse}        $(basename "$0") ${bold3}[option]${cleanse}
${bold2}Description:${cleanse}  $(grep '^# Description: ' "$0" | sed 's/# Description: //g')
${bold2}Dependencies:${cleanse} $(grep '^# Dependencies: ' "$0" | sed 's/# Dependencies: //g')

The folowing ${bold3}OPTIONS${cleanse} are accepted:
    -h  displays this help page
    -a  displays all the information; leaves downloaded PKGBUILDs on system.
    -A  displays all the information; runs a clean-up afterwards.
    -c  displays only PKGBUILDs that have changed; leaves downloaded PKGBUILDs on system.
    -C  displays only PKGBUILDs that have changed; runs a clean-up afterwards.

Running" " $(basename "$0") " "without any argument defaults to using '-a'."
}

all() {
  for x in "${x86_list[@]}"; do
    cd "${dir_path}"/x86_64/"${x}"
    paru -G "${x}" &>/dev/null || echo -e "${bold2}@@ PKGBUILD not available:${cleanse} ${x} is not in the AUR."
    if [ -f "${x}/PKGBUILD" ]; then
      if cmp --quiet "PKGBUILD" "${x}/PKGBUILD"; then
        echo -e "${bold3}## Checking the PKGBUILD:${cleanse}  PKGBUILD for ${x} has not changed."
      else
        echo -e "${bold4}++ Checking the PKGBUILD:${cleanse}  PKGBUILD for ${x} has changed."
      fi
    fi
  done
}

changed() {
  for x in "${x86_list[@]}"; do
    cd "${dir_path}"/x86_64/"${x}"
    paru -G "${x}" &>/dev/null || echo "@@ Can't download PKGBUILD; ${x} is not in the AUR." &>/dev/null
    if [ -f "${x}/PKGBUILD" ]; then
      if ! cmp --quiet "PKGBUILD" "${x}/PKGBUILD"; then
        echo -e "${bold4}++ Checking the PKGBUILD:${cleanse}  PKGBUILD for ${x} has changed."
      fi
    fi
  done
}

noOpt=1
while getopts "aAcCh" arg 2>/dev/null; do
  case "${arg}" in
  a) all ;;
  A) all && cd "${dir_path}" && ./clean-up.sh &>/dev/null ;;
  c) changed ;;
  C) changed && ./clean-up.sh ;;
  h) help ;;
  *) printf '%s\n' "Error: invalid option" "Type $(basename "$0") -h for help" ;;
  esac
  noOpt=0
done

# If script is run with NO argument, it will use 'dmenu'
[ $noOpt = 1 ] && all

tput sgr0
