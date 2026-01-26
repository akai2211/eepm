#!/bin/sh

PKGNAME=spo-anketa
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="СПО «Анкета ГС (МС)» для заполнения анкеты госслужащего"
URL="https://gossluzhba.gov.ru/spo/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Download URL for Linux version from gossluzhba.gov.ru
# Version 1.0.1 from 21.01.2026
PKGURL="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/4f447535-4219-46bf-8bc0-fc4fa18968e5"

# Checksum for version 1.0.1 (2026-01-21) - update when new version is released
PKGSUM="sha256:12083b9c788772afde7d00872812daeb863fed4da0ac254e0da122e10b6e29c0"

install_pack_pkgurl "" "$PKGSUM"
