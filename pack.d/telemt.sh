#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

mkdir -p opt/$PRODUCT
cp "$TAR" opt/$PRODUCT/$PRODUCT
chmod 755 opt/$PRODUCT/$PRODUCT

[ -n "$VERSION" ] || VERSION="1.0"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
ln -s /opt/$PRODUCT/$PRODUCT usr/bin/$PRODUCT

mkdir -p etc
cat <<EOF >etc/$PRODUCT.toml
# Telemt MTProxy configuration
# See https://github.com/telemt/telemt for details

[general]
seed = ""

[server]
port = 8443

[[users]]
name = "user1"
secret = ""
EOF

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Proxy
license: MIT
url: https://github.com/telemt/telemt
summary: Telemt MTProxy - high-performance Telegram proxy server
description: High-performance MTProxy server for Telegram written in Rust + Tokio. Supports classic, secure and fake-TLS modes with connection pooling, replay protection and traffic masking.
EOF

erc pack $PKGNAME.tar opt usr etc || fatal

return_tar $PKGNAME.tar
