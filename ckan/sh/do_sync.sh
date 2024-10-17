#!/bin/sh

# Set the source and destination directories
TMP_SRC_DIR="/root/extensions/"
DEST_DIR="$SRC_EXTENSIONS_DIR"
# Step 1: Remove all contents of the destination directory
echo "Cleaning destination directory contents..."
find "${DEST_DIR}" -mindepth 1 -delete
# Step 3: Perform the rsync
echo "Syncing extensions..."
rsync -av \
  --exclude '*requirements*.txt' \
  --exclude '*requirements*.in' \
  --exclude '*requirements.py[23].txt' \
  "${TMP_SRC_DIR}" "${DEST_DIR}"
# Step 4: Set ownership
echo "Setting ownership..."
chown -R root:root "${DEST_DIR}"
echo "Sync complete."