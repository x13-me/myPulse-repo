#!/bin/sh
set -eu

# Build wrapper for os-mypulse
# This is called from GitHub Actions inside FreeBSD VM

echo "Building os-mypulse..."

# Ensure we're in the right place
if [ ! -f ./build.sh ]; then
    echo "ERROR: build.sh not found in current directory" >&2
    exit 1
fi

# Run the actual build
./build.sh

echo "Build complete."