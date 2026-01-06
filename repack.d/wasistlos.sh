#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/wasistlos

. $(dirname $0)/common.sh

# Remove bundled libwayland - use system ones
# Old bundled libwayland conflicts with system Mesa EGL
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-client.so.0
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-client.so.0.20.0
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-server.so.0
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-server.so.0.20.0
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-cursor.so.0
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-cursor.so.0.20.0
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-egl.so.1
remove_file $PRODUCTDIR/usr/lib/x86_64-linux-gnu/libwayland-egl.so.1.20.0
