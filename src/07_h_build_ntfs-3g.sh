#!/bin/sh

set -e


# Load common properties and functions in the current script.
. ./common.sh

echo "*** BUILD ntfs-3g BEGIN ***"

# Remove the old ntfs-3g install area.
echo "Removing old ntfs-3g artifacts. This may take a while."
rm -rf ntfs-3g_installed

# Change to the source directory ls finds, e.g. 'ntfs-3g_ntfsprogs-2017.3.23'.
cd `ls -d $WORK_DIR/ntfs-3g/ntfs-3g_*`

ls

echo "prepare configure"
./configure

echo "start make"
make

# Create the symlinks for ntfs-3g. The file 'ntfs-3g.links' is used for this.
echo "Generating ntfs-3g based initramfs area."
make \
  CONFIG_PREFIX="ntfs-3g_installed" \
  install -j $NUM_JOBS

cd $SRC_DIR

echo "*** BUILD ntfs-3g END ***"