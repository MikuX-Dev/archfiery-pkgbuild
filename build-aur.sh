#!/usr/bin/env bash
# shellcheck disable=SC2035

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

update_pkg() {
  local pkg="$1"
  # Remove validpgpkeys variable
  sed -i "/validpgpkey=/d" "$pkg"
  # Remove {,.sig} from source line
  sed -i "s/{,.sig}//" "$pkg"
  # Set sha256sums to 'SKIP'
  sed -i "/sha256sums=(/c\sha256sums=('SKIP')" "$pkg"
  # Other changes
  # sed -i 's/LICENSE/license/; s/Maintainer/pkgdesc/; s/depends=(.*$/depends=(knotifyconfig kpty kparts kinit knewstuff)/' "$pkg"
}

packages=("octopi" "megasync-bin" "appmenu-gtk-module-git" "appmenu-qt4" "bluez-firmware" "brave-bin" "caffeine-ng" "downgrade" "eww-x11" "fancontrol-gui" "firebuild" "gtk3-nocsd-git" "libdbusmenu-glib" "libdbusmenu-gtk2" "libdbusmenu-gtk3" "mkinitcpio-firmware" "mkinitcpio-numlock" "mugshot" "nbfc" "obsidian-bin" "ocs-url" "repoctl" "rtl8821ce-dkms-git" "rtw89-dkms-git" "stacer-bin" "tela-icon-theme" "thunar-extended" "thunar-megasync-bin" "thunar-secure-delete" "thunar-shares-plugin" "thunar-vcs-plugin" "universal-android-debloater-bin" "vala-panel-appmenu-common-git" "vala-panel-appmenu-registrar-git" "vala-panel-appmenu-xfce-git" "xfce4-docklike-plugin" "xfce4-panel-profiles" "zsh-theme-powerlevel10k-git" "tlpui" "simplescreenrecorder" "visual-studio-code-bin" "ncurses5-compat-libs" "lib32-ncurses5-compat-libs" "aosp-devel" "xml2" "lineageos-devel" "btrfs-assistant" "snapper-gui-git" "firmware-manager" "yay-bin")

for package in "${packages[@]}"; do
  git clone https://aur.archlinux.org/"$package".git /tmp/pkg-build/"$package"
  cd /tmp/pkg-build/"$package" || exit
  update_pkg PKGBUILD
  makepkg -cs --noconfirm --needed --noprogressbar --skippgpcheck --skipchecksums --nosign
  cp -r *.pkg.tar.* /home/builder/output
  cd -
done

pkgsize=$(du -s *.pkg.tar.* | cut -f1)
if [ "$pkgsize" -gt $((100 * 1024)) ]; then
  echo "$package >= 100MB"
  mv /home/builder/output/*.pkg.tar.* /home/builder/output-large
else
  mv /home/builder/output/*.pkg.tar.* /home/builder/output-small
fi
