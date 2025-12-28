#!/bin/sh

PKGNAME=trilium
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Trilium Notes - personal knowledge base"
URL="https://triliumnotes.org"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

pkgtype="$(epm print info -p)"
case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype=deb
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/TriliumNext/Notes/" "TriliumNextNotes-*-linux-$arch.$pkgtype")
else
    PKGURL="https://github.com/TriliumNext/Notes/releases/download/v$VERSION/TriliumNextNotes-v$VERSION-linux-$arch.$pkgtype"
fi

install_pkgurl
