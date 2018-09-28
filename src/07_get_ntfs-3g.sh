#!/bin/sh

set -e


# Load common properties and functions in the current script.
. ./common.sh

echo "*** GET ntfs-3g BEGIN ***"

# Extract the ntfs-3g sources in the 'work/ntfs-3g' directory.
extract_source externalLibs/ntfs-3g_ntfsprogs-2017.3.23.tgz ntfs-3g

# We go back to the main MLL source folder.
cd $SRC_DIR

echo "*** GET ntfs-3g END ***"
