#!/usr/bin/env bash
# shellcheck disable=SC2035

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

cd /home/builder

# Function to categorize packages based on size
categorize_packages() {
  local input_dir="$1"
  local large_output_dir="/home/builder/output-large"
  local small_output_dir="/home/builder/output-small"

  mkdir -p "$large_output_dir" "$small_output_dir"

  for pkg_file in "$input_dir"/*.pkg.tar.*; do
    size=$(du -m "$pkg_file" | cut -f1)
    if [ "$size" -gt 100 ]; then
      cp -r "$pkg_file" "$large_output_dir"
    else
      cp -r "$pkg_file" "$small_output_dir"
    fi
  done
}

#  >>>-----------------> "eww-x11" needed for archiso <--------------------<<<
packages=("aosp-devel" "appmenu-gtk-module-git" "appmenu-qt4" "bluez-firmware" "brave-bin" "btrfs-assistant" "caffeine-ng" "downgrade" "fancontrol-gui" "firebuild" "firmware-manager" "gtk3-nocsd-git" "lib32-ncurses5-compat-libs" "libdbusmenu-glib" "libdbusmenu-gtk2" "libdbusmenu-gtk3" "lineageos-devel" "megasync-bin" "mkinitcpio-firmware" "mkinitcpio-numlock" "mugshot" "nbfc" "ncurses5-compat-libs" "obsidian-bin" "ocs-url" "octopi" "pomatez" "repoctl" "simplescreenrecorder" "snapper-gui-git" "stacer-bin" "tela-icon-theme" "thunar-extended" "thunar-megasync-bin" "thunar-secure-delete" "thunar-shares-plugin" "thunar-vcs-plugin" "tlpui" "universal-android-debloater-bin" "vala-panel-appmenu-common-git" "vala-panel-appmenu-registrar-git" "vala-panel-appmenu-xfce-git" "visual-studio-code-bin" "xfce4-docklike-plugin" "xfce4-panel-profiles" "xml2" "yay-bin" "zsh-theme-powerlevel10k-git" "eww-x11")

yay -S --noconfirm --needed "${packages[@]}"

OUTPUT_DIR=/home/builder/output
YAY_DIR=/home/builder/.cache/yay/

for dir in "$YAY_DIR"/*/; do
  cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
done

# Categorize packages based on size
categorize_packages "$OUTPUT_DIR"

# update_pkg() {
#   local pkg="$1"
#   # Remove validpgpkeys variable
#   sed -i "/validpgpkey=/d" "$pkg"
#   # Remove {,.sig} from source line
#   sed -i "s/{,.sig}//" "$pkg"
#   # Set sha256sums to 'SKIP'
#   sed -i "/sha256sums=(/c\sha256sums=('SKIP')" "$pkg"
#   # Other changes
#   # sed -i 's/LICENSE/license/; s/Maintainer/pkgdesc/; s/depends=(.*$/depends=(knotifyconfig kpty kparts kinit knewstuff)/' "$pkg"
# }

# pikaur -G "$package"
# update_pkg ./"$package"/PKGBUILD
# cd ./"$package"/PKGBUILD
# makepkg -cs --noconfirm --needed --noprogressbar --skippgpcheck --skipchecksums --nosign ./"$package"/PKGBUILD
# cp -r ./*.pkg.tar.* /home/builder/output
# cd -

# cp -r "$PIK_DIR"/* "$OUTPUT_DIR"

# for package in "${packages[@]}"; do
# pikaur -Sw --noconfirm --needed --keepbuilddeps --nodiff "$package"

# git clone https://aur.archlinux.org/"$package".git /tmp/pkg-build/"$package"
# cd /tmp/pkg-build/"$package" || exit
# makepkg -cs --noconfirm --needed --noprogressbar --skippgpcheck --skipchecksums --nosign
# cp -r *.pkg.tar.* /home/builder/output
# cd -
# done
