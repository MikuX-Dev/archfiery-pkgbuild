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

#  >>>-----------------> "eww-x11" needed for archiso <--------------------<<<
packages=("aosp-devel" "appmenu-gtk-module-git" "appmenu-qt4" "bluez-firmware" "brave-bin" "btrfs-assistant" "caffeine-ng" "downgrade" "fancontrol-gui" "firebuild" "firmware-manager" "gtk3-nocsd-git" "lib32-ncurses5-compat-libs" "libdbusmenu-glib" "libdbusmenu-gtk2" "libdbusmenu-gtk3" "lineageos-devel" "megasync-bin" "mkinitcpio-firmware" "mkinitcpio-numlock" "mugshot" "nbfc" "ncurses5-compat-libs" "obsidian-bin" "ocs-url" "octopi" "pomatez" "repoctl" "rtl8821ce-dkms-git" "rtw89-dkms-git" "simplescreenrecorder" "snapper-gui-git" "stacer-bin" "tela-icon-theme" "thunar-extended" "thunar-megasync-bin" "thunar-secure-delete" "thunar-shares-plugin" "thunar-vcs-plugin" "tlpui" "universal-android-debloater-bin" "vala-panel-appmenu-common-git" "vala-panel-appmenu-registrar-git" "vala-panel-appmenu-xfce-git" "visual-studio-code-bin" "xfce4-docklike-plugin" "xfce4-panel-profiles" "xml2" "yay-bin" "zsh-theme-powerlevel10k-git" "pikaur")

for package in "${packages[@]}"; do
  # pikaur -Sw --noconfirm --needed --keepbuilddeps --nodiff "$package"

  yay -S --noconfirm --needed "$package"

  OUTPUT_DIR=/home/builder/output
  YAY_DIR=/home/builder/.cache/yay

  for dir in "$YAY_DIR"/*/; do
    cp "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done

  # git clone https://aur.archlinux.org/"$package".git /tmp/pkg-build/"$package"
  # cd /tmp/pkg-build/"$package" || exit
  # makepkg -cs --noconfirm --needed --noprogressbar --skippgpcheck --skipchecksums --nosign
  # cp -r *.pkg.tar.* /home/builder/output
  # cd -
done

pkgsize=$(du -s *.pkg.tar.* | cut -f1)
if [ "$pkgsize" -gt $((100 * 1024)) ]; then
  echo "$package >= 100MB"
  cp -r /home/builder/output/*.pkg.tar.* /home/builder/output-large
else
  cp -r /home/builder/output/*.pkg.tar.* /home/builder/output-small
fi
