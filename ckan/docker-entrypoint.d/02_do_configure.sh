#!/bin/bash

# Function to add a configuration using ckan config-tool
add_config() {
    local key="$1"
    local value="$2"
    echo "Setting $key in CKAN config file"
    ckan config-tool "$CKAN_INI" "$key=$value"
}

# Function to read and apply configurations from a file
apply_configs_from_file() {
    local config_file="$1"
    echo "Applying configurations from $config_file"

    if [ ! -f "$config_file" ]; then
        echo "Error: $config_file does not exist."
        return 1
    fi

    while IFS='=' read -r key value
    do
        # Trim leading and trailing whitespace
        key=$(echo "$key" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        if [ -n "$key" ] && [ -n "$value" ]; then
            add_config "$key" "$value"
        else
            echo "Skipped invalid line: $key=$value"
        fi
    done < "$config_file"
}

# Main execution
main() {
    # Check if CKAN_INI is set
    if [ -z "$CKAN_INI" ]; then
        echo "Error: CKAN_INI environment variable is not set."
        exit 1
    fi

    # Check if INI_CONFIG_LINES is set
    if [ -z "$INI_CONFIG_LINES" ]; then
        echo "Error: INI_CONFIG_LINES environment variable is not set."
        exit 1
    fi

    # Set ownership for CKAN i18n directory
    chown -R ckan:ckan /srv/app/src/ckan/ckan/public/base/i18n

    # Apply configurations from file
    apply_configs_from_file "$INI_CONFIG_LINES"
    echo "CKAN configuration update complete."
}

# Run the main function
main
