#!/bin/sh

PKGNAME=git-butler
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GitButler - Git client for modern workflows (branches, undo, AI)"
URL="https://gitbutler.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # Get version and build number from AUR PKGBUILD
    pkgbuild=$(eget -q -O- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=gitbutler-bin")
    VERSION=$(echo "$pkgbuild" | grep -oP '^pkgver=\K.*')
    BUILD=$(echo "$pkgbuild" | grep -oP '^_pkgvernum=\K.*')
    [ -n "$VERSION" ] && [ -n "$BUILD" ] || fatal "Can't get version"
    VERSION="$VERSION-$BUILD"
fi

# VERSION format: 0.18.3-2698
ver=$(echo "$VERSION" | cut -d- -f1)
build=$(echo "$VERSION" | cut -d- -f2)

PKGURL="https://releases.gitbutler.com/releases/release/$VERSION/linux/x86_64/GitButler_${ver}_amd64.deb"

install_pkgurl
