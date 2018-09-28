#!/bin/sh
set -e

. ../../common.sh

cp "$SRC_DIR/99_hello.sh" "$OVERLAY_ROOTFS/etc/autorun/99_hello.sh"

echo "HelloWorld scripts and libraries have been installed."