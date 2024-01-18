#!/usr/bin/env bash

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

CHROOT=/build-chroot
echo "$CHROOT is archlinux pkg build folder!"
sleep 5s
mkarchroot $CHROOT/root base-devel devtools
arch-nspawn $CHROOT/root pacman -Syu

for dir in x86_64/*/; do
  cd "$dir"
  # mkarchroot -c -r $CHROOT
  makepkg -csf --noconfirm --needed --noprogressbar || exit 1
  cd -
done

echo "Done building packages"

# for dir in x86_64/*/; do
#   cd "$dir"
#   NAME=${dir%*/}
#   curl -sSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$NAME" -o ./PKGBUILD
#   if [ -f PKGBUILD ]; then
#     if cmp --silent -- "PKGBUILD" "./PKGBUILD"; then
#       echo "## Checking the PKGBUILD: PKGBUILD for $NAME has not changed."
#       makepkg -sf --noconfirm --needed --noprogressbar
#     else
#       echo "++ Checking the PKGBUILD: PKGBUILD for $NAME has changed."
#       mv "./PKGBUILD" PKGBUILD
#       makepkg -sf --noconfirm --needed --noprogressbar || echo "FAILED TO MAKE PACKAGE: $NAME"
#     fi
#   else
#     echo "@@ PKGBUILD not available: $NAME is not in the AUR. Skipping!"
#   fi
#   cd -
# done
