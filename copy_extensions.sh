#!/bin/bash

# Check if the container is running
if ! docker ps | grep -q ckan-dev; then
    echo "Error: ckan-dev container is not running"
    exit 1
fi

# Create the destination directory in the container
docker exec ckan-dev mkdir -p /srv/app/src_extensions

# Copy each item in the source directory to the container
for item in ./ckan/extensions/*; do
    if [ -e "$item" ]; then
        docker cp "$item" ckan-dev:/srv/app/src_extensions/
    fi
done

echo "Extensions copied successfully"