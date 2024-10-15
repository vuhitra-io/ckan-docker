#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to install requirements
install_requirements() {
    echo "Installing requirements..."
    pip install -r /root/requirements.txt
}

# Function to check for errors and provide feedback
check_installation() {
    if [ $? -eq 0 ]; then
        echo "Installation completed successfully."
    else
        echo "Error: Installation failed. Please check the error messages above."
        exit 1
    fi
}

# Main execution
main() {
    find "$SRC_EXTENSIONS_DIR"/ -type f \( \
        -name '*requirements*.txt' -o \
        -name '*requirements*.in' -o \
        -name '*requirements.py[23].txt' \
    \) -delete
    install_requirements
    check_installation
}

# Run the main function
main