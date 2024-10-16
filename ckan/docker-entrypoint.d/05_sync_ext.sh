#!/bin/bash

# Set ownership for CKAN i18n directory
chown -R ckan:ckan /srv/app/src/ckan/ckan/public/base/i18n

# Function to check if CKAN is up
check_ckan() {
    wget -q -O /dev/null http://0.0.0.0:5000
    return $?
}

# Wait for CKAN to be up
echo "Waiting for CKAN to start..."
while ! check_ckan; do
    echo "CKAN is not up yet. Waiting..."
    sleep 5
done
echo "CKAN is up and running!"

# Start the watch_sync.sh script
echo "Starting watch_sync.sh"
/root/watch_sync.sh &

# Run the original command (likely to start CKAN)
exec "$@"