#!/usr/bin/env bash

# Script name: build-packages.sh
# Description: Script for automating pkg builds.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

exit

# mkdir -p /build-chroot
# CHROOT=/build-chroot
# mkarchroot $CHROOT/root base-devel devtools
# arch-nspawn $CHROOT/root pacman -Syu
