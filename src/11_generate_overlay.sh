#!/bin/sh

set -e

echo "*** GENERATE OVERLAY BEGIN ***"

SRC_DIR=$(pwd)

# Remove the old ISO generation area if it exists.
echo "Removing old overlay area. This may take a while."
rm -rf work/isoimage_overlay
mkdir -p work/isoimage_overlay
cd work/isoimage_overlay

# Read the 'OVERLAY_TYPE' property from '.config'
OVERLAY_TYPE="$(grep -i ^OVERLAY_TYPE $SRC_DIR/.config | cut -f2 -d'=')"

# Read the 'OVERLAY_LOCATION' property from '.config'
OVERLAY_LOCATION="$(grep -i ^OVERLAY_LOCATION $SRC_DIR/.config | cut -f2 -d'=')"

if [ "$OVERLAY_LOCATION" = "iso" \
  -a "$OVERLAY_TYPE" = "sparse" \
  -a -d $SRC_DIR/work/overlay_rootfs \
  -a "$(id -u)" = "0" ] ; then

  # Use sparse file as storage place. The above check guarantees that the whole
  # script is executed with root permissions or otherwise this block is skipped.
  # All files and folders located in the folder 'minimal_overlay' will be merged
  # with the root folder on boot.

  echo "Using sparse file for overlay."

  # This is the BusyBox executable that we have already generated.
  BUSYBOX=../rootfs/bin/busybox

  # Create sparse image file with 1MB size. Note that this increases the ISO
  # image size.
  $BUSYBOX truncate -s 1M minimal.img

  # Find available loop device.
  LOOP_DEVICE=$($BUSYBOX losetup -f)

  # Associate the available loop device with the sparse image file.
  $BUSYBOX losetup $LOOP_DEVICE minimal.img

  # Format the sparse image file with Ext2 file system.
  $BUSYBOX mkfs.ext2 $LOOP_DEVICE

  # Mount the sparse file in folder 'sparse".
  mkdir sparse
  $BUSYBOX mount minimal.img sparse

  # Create the overlay folders.
  mkdir -p sparse/rootfs
  mkdir -p sparse/work

  # Copy the overlay content.
  cp -r $SRC_DIR/overlay_rootfs/* sparse/rootfs
  cp -r $SRC_DIR/minimal_overlay/rootfs/* sparse/rootfs

  # Unmount the sparse file and delete the temporary folder.
  $BUSYBOX umount sparse
  rm -rf sparse

  # Detach the loop device since we no longer need it.
  $BUSYBOX losetup -d $LOOP_DEVICE

  echo "Applying original ownership to all affected files and folders."
  chown -R $(logname) .
elif [ "$OVERLAY_LOCATION" = "iso" \
  -a "$OVERLAY_TYPE" = "folder" \
  -a -d $SRC_DIR/work/overlay_rootfs ] ; then

  # Use normal folder structure for overlay. All files and folders located in
  # the folder 'minimal_overlay' will be merged with the root folder on boot.

  echo "Using folder structure for overlay."

  # Create the overlay folders.
  mkdir -p minimal/rootfs
  mkdir -p minimal/work

  # Copy the overlay content.
  cp -rf $SRC_DIR/work/overlay_rootfs/* minimal/rootfs
  cp -r $SRC_DIR/minimal_overlay/rootfs/* minimal/rootfs
else
  echo "The ISO image will have no overlay structure."
fi

cd $SRC_DIR

echo "*** GENERATE OVERLAY END ***"