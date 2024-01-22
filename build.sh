#!/usr/bin/env bash
# shellcheck disable=SC2035
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Script for automating pkgbuild on "ci".
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# Default values
OUTPUT_DIR="$HOME/output"
AURBUILD="$HOME/aur-build"
PKGSTXT="$HOME/archfiery-pkgbuild/packages"
PARUCACHE="$HOME/.cache/paru/clone"
YAYCACHE="$HOME/.cache/yay"
LOCALPKG="$HOME/archfiery-pkgbuild/packages"

# Find the *.txt file in $PKGSTXT
TXT_FILE=$(find "$PKGSTXT" -maxdepth 1 -type f -name "*.txt" | head -n 1)

# Check if a *.txt file is found
if [ -z "$TXT_FILE" ]; then
  echo "Error: No *.txt file found in $HOME"
  exit 1
fi

un_comment_makeconf() {
  sudo sed -i 's|^#MAKEFLAGS.*|MAKEFLAGS="-j$(nproc)"|g' /etc/makepkg.conf
  # sudo sed -i 's|^#BUILDDIR.*|BUILDDIR=/tmp/makepkg|g' /etc/makepkg.conf
}

# Directories to be used within the script
declare -a dirs=(
  "$OUTPUT_DIR"
  "$AURBUILD"
  "$HOME/output-large"
  "$HOME/output-small"
  # "$HOME/log/"
)

# Function to create directories
create_directories() {
  mkdir -p "${dirs[@]}"
}

clone_pkg() {
  pushd "$AURBUILD"
  while IFS= read -r package; do
    # Skip lines starting with #
    [[ $package =~ ^# ]] && continue
    git clone https://aur.archlinux.org/"$package"
  done <"$TXT_FILE"
  popd
}

# Function to install AUR dependencies
install_aur_deps() {
  source ./PKGBUILD
  local all_deps=("${depends[@]}" "${makedepends[@]}")

  for dep in "${all_deps[@]}"; do
    if pacman -Ss "$dep" >/dev/null 2>&1; then
      paru -S --needed --noconfirm --asdeps --sudoloop --cleanafter --skipreview "$dep"
    else
      yay -S --needed --noconfirm --asdeps --sudoloop "$dep"
    fi
  done
}

iad() {
  clone_pkg

  for dir in "$AURBUILD"/*/; do
    pushd "$dir"
    install_aur_deps
    popd
  done
}

# Function to build packages in parallel
build_packages_parallel() {
  local package_dirs=("$@")

  parallel --bar ::: "makepkg --clean --needed --nodeps --noconfirm --skippgpcheck --skipchecksums --skipinteg --noprogressbar" ::: "${package_dirs[@]}"
}

build_aur_packages() {
  local package_dirs=("$AURBUILD"/*/)
  build_packages_parallel "${package_dirs[@]}"
}

build_local_packages() {
  local package_dirs=("$LOCALPKG"/*/)
  build_packages_parallel "${package_dirs[@]}"
}

copy_aur_deps() {
  for dir in "$PARUCACHE"/*/; do
    cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done

  for dir in "$YAYCACHE"/*/; do
    cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done
}

copy_build_pkg() {
  for dir in "$AURBUILD"/*/; do
    cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done
}

copy_build_local() {
  for dir in "$LOCALPKG"/*/; do
    cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done
}

# Function to categorize packages based on size
categorize_packages() {
  local input_dir="$1"
  local large_output_dir="$HOME/output-large"
  local small_output_dir="$HOME/output-small"

  for pkg_file in "$input_dir"/*.pkg.tar.*; do
    local size
    size=$(du -m "$pkg_file" | cut -f1)
    if ((size > 100)); then
      mv -f "$pkg_file" "$large_output_dir"
    else
      mv -f "$pkg_file" "$small_output_dir"
    fi
  done
}

# Main execution flow
main() {
  create_directories
  un_comment_makeconf
  iad
  build_aur_packages
  build_local_packages
  copy_aur_deps
  copy_build_pkg
  categorize_packages "$OUTPUT_DIR"
}

main
