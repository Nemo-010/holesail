#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=DUMMY
export ICON=DUMMY
export MAIN_BIN=/usr/bin/holesail

# Deploy dependencies
quick-sharun "$MAIN_BIN"

# Turn AppDir into AppImage
quick-sharun --make-appimage

# holesail is a CLI: running it with no arguments prints help and exits,
# so only check that the bundled libraries load
quick-sharun --simple-test ./dist/*.AppImage --version
