#!/usr/bin/env bash

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

for dir in x86_64/*/; do
  cd "$dir"
  # mkarchroot -c -r $CHROOT
  makepkg -csf --noconfirm --needed --noprogressbar || exit 1
  cd -
done

for dir in x86_64/*/; do
  cp -r "$dir"/*.tar.* archfiery-repo/x86_64/
done

echo "Done building packages"
