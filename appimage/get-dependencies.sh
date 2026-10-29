#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm --needed \
	clang cmake git ninja nodejs npm python

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

case "$ARCH" in
	x86_64) BARE_ARCH=x64 ;;
	aarch64) BARE_ARrm64 ;;
	*) BARE_ARCH=$ARCH ;;
esac

echo "Installing bare-make..."
echo "---------------------------------------------------------------"
npm install -g bare-make

echo "Building holesail for linux-$BARE_ARCH..."
echo "---------------------------------------------------------------"
npm install
bare-make generate --platform linux --arch "$BARE_ARCH"
bare-make build
bare-make install --strip --prefix ./install

install -Dm755 ./install/bin/holesail /usr/bin/holesail

node -p "require('./package.json').version" > ~/version
