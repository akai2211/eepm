#!/bin/sh

PKGNAME=wasistlos
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WasIstLos - an unofficial WhatsApp desktop application"
URL="https://github.com/xeco23/WasIstLos"

. $(dirname $0)/common.sh

arch=x86_64
PKGURL=$(eget --list --latest https://github.com/xeco23/WasIstLos/releases/download "$PKGNAME-$VERSION-$arch.AppImage")

install_pkgurl
