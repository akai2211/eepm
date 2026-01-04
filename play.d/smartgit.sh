#!/bin/sh

PKGNAME=smartgit
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="SmartGit - Git GUI client with GitHub, GitLab, Bitbucket integration"
URL="https://www.syntevo.com/smartgit/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -q -O- https://www.smartgit.dev/download/ | grep -oP 'smartgit-\K[0-9_]+(?=-linux-amd64\.tar\.gz)' | head -1)
    [ -n "$VERSION" ] || fatal "Can't get version"
fi

PKGURL="https://download.smartgit.dev/smartgit/smartgit-$VERSION-linux-amd64.tar.gz"

install_pack_pkgurl
