#!/usr/bin/env bash

# Script name: build-docker.sh
# Description: Script for building and runnig dockerfile.
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# build and run docker
docker build -t archpkgb -f docker/Dockerfile
docker run --rm archpkgb

# Exec the build-packages.sh
chmod 755 build-packages.sh
./build-packages.sh
