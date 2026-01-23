#!/bin/sh

PKGNAME=fresh-editor
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Fresh - terminal text editor with modern UX and LSP support"
URL="https://github.com/sinelaw/fresh"

. $(dirname $0)/common.sh

arch="$(epm print info --distro-arch)"
pkgtype="$(epm print info -p)"

case "$pkgtype" in
    rpm|deb)
        ;;
    *)
        pkgtype=rpm
        ;;
esac

# https://github.com/sinelaw/fresh/releases/download/v0.1.88/fresh-editor-0.1.88-1.x86_64.rpm
# https://github.com/sinelaw/fresh/releases/download/v0.1.88/fresh-editor_0.1.88-1_amd64.deb
case "$pkgtype" in
    rpm)
        PKGURL="$(get_github_url sinelaw/fresh fresh-editor-${VERSION}-${RELEASE}.$arch.rpm)"
        ;;
    deb)
        PKGURL="$(get_github_url sinelaw/fresh fresh-editor_${VERSION}-${RELEASE}_$arch.deb)"
        ;;
esac

install_pkgurl
