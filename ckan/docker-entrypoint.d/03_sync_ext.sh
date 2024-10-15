#!/bin/bash

if [ "$STAGE" = "development" ]; then
  /root/watch_sync.sh &
  echo "We are in development stage, syncing ..."
else
    echo "We are not in development stage, no syncing ..."
fi
