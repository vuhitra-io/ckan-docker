#!/bin/bash


# Function to install requirements
install_requirements() {
    echo "Installing requirements..."
    pip install -r $REQUIREMENTS_FILE
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
    for d in ${SRC_EXTENSIONS_DIR}/ckanext-*; do
        if [ -d "$d" ]; then
            install_extension "$d"
        fi
    done

    # init database
    # ckan --config $CKAN_INI db init
    # prerun already does this
}

# Run the main function
main
