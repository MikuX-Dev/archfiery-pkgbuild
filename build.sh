#!/usr/bin/env bash

# Use more efficient way to loop through directories
shopt -s nullglob dotglob

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing. Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# Default values
OUTPUT_DIR="$HOME/output"
AURBUILD="$HOME/aur-build"
PKGSTXT="$HOME/archfiery-pkgbuild/packages"
YAYCACHE="$HOME/.cache/yay"
LOCALPKG="$HOME/archfiery-pkgbuild/packages"

# Use fd instead of find
TXT_FILE=$(fd --type f --max-depth 1 --full-path --extension txt "$PKGSTXT")

# Check if a *.txt file is found
if [ -z "$TXT_FILE" ]; then
  echo "Error: No *.txt file found in $HOME"
  exit 1
fi

un_comment_jmake() {
  sudo sed -i 's|^#MAKEFLAGS.*|MAKEFLAGS="-j$(nproc)"|g' /etc/makepkg.conf
  sudo sed -i 's|^#BUILDDIR.*|BUILDDIR=/tmp/makepkg|g' /etc/makepkg.conf
}

# Function to create directories
create_directories() {
  mkdir -p "${dirs[@]}"
}

# Avoid repeated pushd/popd
clone_pkg() {
  cd "$AURBUILD"
  for dir in */; do
    cd "$dir"
    git clone https://aur.archlinux.org/"$package"
  done
  cd -
}

# Function to check if a package is in the official repositories
is_in_repos() {
  pacman -Ss "$1" >/dev/null 2>&1
}

# Function to install AUR dependencies
install_aur_deps() {
  source ./PKGBUILD
  local all_deps=("${depends[@]}" "${makedepends[@]}")

  for dep in "${all_deps[@]}"; do
    if ! is_in_repos "$dep"; then
      echo "Installing AUR dependency: $dep"
      yay -S --needed --noconfirm --asdeps --sudoloop "$dep"
    else
      sudo pacman -S --needed --noconfirm --asdeps "$dep"
    fi
  done
}

iad() {
  clone_pkg
  for dir in "$AURBUILD"/*/; do
    cd "$dir"
    install_aur_deps
    cd -
  done
}

# Parallelize building packages
build_aur_packages() {
  local -a pkgdirs=("$AURBUILD"/*/)

  # Build in parallel
  printf '%s\0' "${pkgdirs[@]}" | xargs -0 -n1 -P$(nproc) -I{} makepkg --clean --needed --noconfirm --skippgpcheck --skipchecksums --skipinteg --noprogressbar {}
}

build_local_packages() {
  for dir in "$LOCALPKG"/*/; do
    cd "$dir"
    makepkg --clean --needed --nodeps --noconfirm --skippgpcheck --skipchecksums --skipinteg --noprogressbar
    cd -
  done
}

copy_aur_deps() {
  cp -r "$YAYCACHE"/*/*.pkg.tar.* "$OUTPUT_DIR"
}

copy_build_pkg() {
  cp -r "$AURBUILD"/*/*.pkg.tar.* "$OUTPUT_DIR"
}

# Use more efficient mv
categorize_packages() {
  local large_output_dir="$HOME/output-large"
  local small_output_dir="$HOME/output-small"

  fd --type f --extension pkg.tar.* "$1" | while IFS= read -r pkg_file; do
    if [[ $(du -m "$pkg_file" | cut -f1) -gt 100 ]]; then
      mv -f "$pkg_file" "$large_output_dir"
    else
      mv -f "$pkg_file" "$small_output_dir"
    fi
  done
}

# Main execution flow
main() {
  create_directories
  un_comment_jmake
  iad
  build_aur_packages
  build_local_packages
  copy_aur_deps
  copy_build_pkg
  categorize_packages "$OUTPUT_DIR"
}

main
