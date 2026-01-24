#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=pantum

. $(dirname $0)/common.sh

if [ -d "$BUILDROOT/usr/lib/sane" ] ; then
    mkdir -p "$BUILDROOT/usr/lib64/sane"
    for f in "$BUILDROOT/usr/lib/sane/"* ; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        move_file "/usr/lib/sane/$name" "/usr/lib64/sane/$name"
    done
    remove_dir /usr/lib/sane
fi

if [ "$(epm print info -p)" = "rpm" ] ; then
    mv usr/lib/x86_64-linux-gnu usr/lib64
    subst 's|/usr/lib/x86_64-linux-gnu|/usr/lib64|' $SPEC
fi

# Debian style duplicates
remove_dir /usr/lib/aarch64-linux-gnu
remove_dir /usr/lib/arm-linux-gnueabihf
remove_dir /usr/lib/i386-linux-gnu
remove_dir /usr/lib/x86_64-linux-gnu

# duplicates main files
remove_dir /usr/local
