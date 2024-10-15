#!/bin/sh

while true; do
  # Watch for modifications in /root/extensions
  inotifywait -r -e modify,create,delete,move /root/extensions
  # Sync changes to /srv/app/src_extensions
rsync -av --delete \
  --exclude '*requirements*.txt' \
  --exclude '*requirements*.in' \
  --exclude '*requirements.py[23].txt' \
  /root/extensions/ /srv/app/src_extensions/
  chown -R root:root /srv/app/src_extensions/
done
