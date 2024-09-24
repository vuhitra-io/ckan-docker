#!/bin/bash

# Set the APP_DIR if it's not already set
APP_DIR=${APP_DIR:-/srv/app}

# Function to install an extension
install_extension() {
    local ext_path="$1"
    echo "Installing extension: $ext_path"
    pip3 install -e "$ext_path"

    if [ -f "$ext_path/requirements.txt" ]; then
        echo "Installing requirements for $ext_path"
        pip3 install -r "$ext_path/requirements.txt"
    fi

    if [ -f "$ext_path/dev-requirements.txt" ]; then
        echo "Installing development requirements for $ext_path"
        pip3 install -r "$ext_path/dev-requirements.txt"
    fi
}

# Check if a specific extension name was provided
if [ $# -eq 1 ]; then
    ext_name="$1"
    ext_path="${APP_DIR}/src/${ext_name}"
    if [ -d "$ext_path" ]; then
        install_extension "$ext_path"
    else
        echo "Extension directory not found: $ext_path"
        exit 1
    fi
else
    # Install all extensions in the src directory
    for d in ${APP_DIR}/src/ckanext-*; do
        if [ -d "$d" ]; then
            install_extension "$d"
        fi
    done
fi

echo "Extension installation complete"