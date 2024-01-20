#!/usr/bin/env bash
# Script name: build.sh
# Description: Script for automating pkgbuild on "ci".
# Contributors: MikuX-Dev

# Set strict shell options for error handling
set -euo pipefail

# Default values
OUTPUT_DIR="$HOME/output"
AURBUILD="$HOME/aur-build"
PKGSTXT="$HOME/archfiery-pkgbuild/packages"
YAYCACHE="$HOME/.cache/yay"
LOCALPKG="$HOME/archfiery-pkgbuild/packages"

# Find the *.txt file in $PKGSTXT
TXT_FILE=$(find "$PKGSTXT" -maxdepth 1 -type f -name "*.txt" | head -n 1)

# Check if a *.txt file is found
if [ -z "$TXT_FILE" ]; then
  echo "Error: No *.txt file found in $HOME"
  exit 1
fi

# Function to uncomment MAKEFLAGS in makepkg.conf
un_comment_jmake() {
  sudo sed -i 's|^#MAKEFLAGS.*|MAKEFLAGS="-j$(nproc)"|g' /etc/makepkg.conf
  sudo sed -i 's|^#BUILDDIR.*|BUILDDIR=/tmp/makepkg|g' /etc/makepkg.conf
}

# Function to create directories
create_directories() {
  mkdir -p "$OUTPUT_DIR" "$AURBUILD" "$HOME/output-large" "$HOME/output-small"
}

# Function to clone AUR packages
clone_pkg() {
  pushd "$AURBUILD"
  xargs -a "$TXT_FILE" -I {} git clone https://aur.archlinux.org/{}
  popd
}

# Function to check if a package is in the official repositories
is_in_repos() {
  pacman -Ss "$1" &>/dev/null
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

# Function to iterate and apply a function on AUR packages
iterate_aur_packages() {
  local function_name="$1"
  for dir in "$AURBUILD"/*/; do
    pushd "$dir"
    $function_name
    popd
  done
}

# Function to build AUR packages
build_aur_packages() {
  makepkg_args=('--clean' '--needed' '--nodeps' '--noconfirm' '--skippgpcheck' '--skipchecksums' '--skipinteg' '--noprogressbar')
  iterate_aur_packages 'makepkg' "${makepkg_args[@]}"
}

# Function to build local packages
build_local_packages() {
  iterate_aur_packages 'makepkg' '--clean --needed --nodeps --noconfirm --skippgpcheck --skipchecksums --skipinteg --noprogressbar'
}

# Function to copy AUR dependencies
copy_aur_deps() {
  find "$YAYCACHE" -mindepth 1 -maxdepth 1 -type d -exec cp -r {}/. "$OUTPUT_DIR" \;
}

# Function to copy built packages
copy_build_pkg() {
  iterate_aur_packages "cp -r *.pkg.tar.* '$OUTPUT_DIR'"
}

# Function to categorize packages based on size
categorize_packages() {
  local input_dir="$1"
  local large_output_dir="$HOME/output-large"
  local small_output_dir="$HOME/output-small"

  find "$input_dir" -name '*.pkg.tar.*' -exec du -m {} + | while read -r size pkg_file; do
    ((size > 100)) && mv -f "$pkg_file" "$large_output_dir" || mv -f "$pkg_file" "$small_output_dir"
  done
}

# Main execution flow
main() {
  create_directories
  un_comment_jmake
  clone_pkg
  install_aur_deps
  build_aur_packages
  build_local_packages
  copy_aur_deps
  copy_build_pkg
  categorize_packages "$OUTPUT_DIR"
}

main
