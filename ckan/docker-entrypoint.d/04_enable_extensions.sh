#!/bin/bash

# Path to the file containing the list of plugins to enable
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PLUGINS_FILE="/root/ckan_plugins.txt"

# Function to add a plugin to CKAN if it's not already enabled
add_plugin() {
    local plugin=$1
    if [[ $CKAN__PLUGINS != *"$plugin"* ]]; then
        echo "Enabling $plugin plugin"
        ckan config-tool $CKAN_INI "ckan.plugins += $plugin"
    else
        echo "$plugin plugin is already enabled"
    fi
}

# Check if the plugins file exists
if [ ! -f "$PLUGINS_FILE" ]; then
    echo "Error: Plugins file not found at $PLUGINS_FILE"
    exit 1
fi

# Read the plugins file and enable each plugin
while IFS='>' read -r repo_url plugin_name || [[ -n "$repo_url" ]]; do
    # Trim whitespace
    plugin_name=$(echo "$plugin_name" | xargs)

    if [ ! -z "$plugin_name" ]; then
        add_plugin "$plugin_name"
    fi
done < "$PLUGINS_FILE"

echo "Extension enabling process complete"