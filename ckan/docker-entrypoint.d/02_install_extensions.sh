#!/bin/bash

# Set the SRC_DIR to the mounted src_extensions directory
SRC_DIR="/srv/app/src_extensions"

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

# Install all extensions in the src_extensions directory
for d in ${SRC_DIR}/ckanext-*; do
    if [ -d "$d" ]; then
        install_extension "$d"
    fi
done

echo "Extension installation complete"