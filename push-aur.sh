#!/usr/bin/env bash
# shellcheck disable=SC2035

# Script name: build-packages.sh
# Description: Script for automating 'makepkg' on the PKGBUILDS.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

cd /home/builder/archfiery-repo/
git lfs install

cd x86_64/
rm -rf ./*.pkg.tar.*

cp -r /home/builder/output-large/* ./

cat >>.gitattributes <<EOF
*.zst filter=lfs diff=lfs merge=lfs -text
*.zst !text !filter !merge !diff
EOF

# Track large packages with Git LFS and echo each name
for package in ./*.pkg.tar.*; do
  name=$(basename "$package")
  echo "Tracking $name with Git LFS"
  git lfs track "$name"
done

mv .gitattributes /home/builder/archfiery-repo/
cp -r /home/builder/output-small/* ./

chmod +x ./update-db.sh
./update-db.sh

cd /home/builder/archfiery-repo/
git config --local user.email "actions@github.com"
git config --local user.name "GitHub Actions"
git add .
git commit -m "Add built packages"
git push
