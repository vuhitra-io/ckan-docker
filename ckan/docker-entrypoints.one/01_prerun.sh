#!/bin/bash
set -e

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        log "Error: $1"
        exit 1
    fi
}

# Function to add a configuration using ckan config-tool
add_config() {
    local key="$1"
    local value="$2"
    log "Setting $key in CKAN config file"
    ckan config-tool "$CKAN_INI" "$key=$value"
    check_command "Failed to set configuration: $key"
}

# Function to apply configurations from a file
apply_configs_from_file() {
    local config_file="$1"
    log "Applying configurations from $config_file"

    if [ ! -f "$config_file" ]; then
        log "Error: $config_file does not exist."
        return 1
    fi

    while IFS='=' read -r key value
    do
        key=$(echo "$key" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        if [ -n "$key" ] && [ -n "$value" ]; then
            add_config "$key" "$value"
        else
            log "Skipped invalid line: $key=$value"
        fi
    done < "$config_file"
}

# Function to install requirements
install_requirements() {
    log "Installing requirements..."
    pip install -r "${REQUIREMENTS_FILE:-/srv/app/src_extensions/requirements.txt}"
    check_command "Failed to install requirements"
}

# Function to sync extensions
sync_extensions() {
    local TMP_SRC_DIR="/root/extensions/"
    local DEST_DIR="${SRC_EXTENSIONS_DIR:-/srv/app/src_extensions}"

    log "Cleaning destination directory contents..."
    find "${DEST_DIR}" -mindepth 1 -delete
    check_command "Failed to clean destination directory"

    log "Syncing extensions..."
    rsync -av \
      --exclude '*requirements*.txt' \
      --exclude '*requirements*.in' \
      --exclude '*requirements.py[23].txt' \
      "${TMP_SRC_DIR}" "${DEST_DIR}"
    check_command "Failed to sync extensions"

    log "Setting ownership..."
    chown -R root:root "${DEST_DIR}"
    check_command "Failed to set ownership"

    log "Sync complete."
}

# Function to install a single extension
install_extension() {
    local ext_path="$1"
    log "Installing extension: $ext_path"
    pip install -e "$ext_path"
    check_command "Failed to install extension: $ext_path"

    if [ -f "$ext_path/requirements.txt" ]; then
        log "Installing requirements for $ext_path"
        pip install -r "$ext_path/requirements.txt"
        check_command "Failed to install requirements for $ext_path"
    fi

    if [ -f "$ext_path/dev-requirements.txt" ]; then
        log "Installing development requirements for $ext_path"
        pip install -r "$ext_path/dev-requirements.txt"
        check_command "Failed to install dev requirements for $ext_path"
    fi
}

# Function to install all extensions
install_all_extensions() {
    local SRC_EXTENSIONS_DIR="${SRC_EXTENSIONS_DIR:-/srv/app/src_extensions}"
    for d in ${SRC_EXTENSIONS_DIR}/ckanext-*; do
        if [ -d "$d" ]; then
            install_extension "$d"
        fi
    done
}

# Function to set and check permissions of the commands file
prepare_commands_file() {
    local COMMAND_FILE="${COMMAND_FILE:-/root/commands.txt}"

    if [ ! -f "$COMMAND_FILE" ]; then
        log "Warning: File '$COMMAND_FILE' not found. Creating an empty file."
        touch "$COMMAND_FILE"
    fi

    log "Setting correct ownership and permissions for $COMMAND_FILE"
    chown root:root "$COMMAND_FILE"
    chmod 644 "$COMMAND_FILE"
    check_command "Failed to set correct ownership and permissions for $COMMAND_FILE"

    if [ "$(stat -c '%U' "$COMMAND_FILE")" != "root" ] || [ "$(stat -c '%a' "$COMMAND_FILE")" != "644" ]; then
        log "Error: Failed to set correct ownership and permissions for '$COMMAND_FILE'"
        return 1
    fi
}

# Function to execute commands from a file
execute_commands_from_file() {
    local COMMAND_FILE="${COMMAND_FILE:-/root/commands.txt}"

    prepare_commands_file
    check_command "Failed to prepare commands file"

    while IFS= read -r line || [[ -n "$line" ]]; do
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        if [ -z "$line" ] || [[ "$line" == \#* ]]; then
            continue
        fi

        log "Executing: $line"
        eval "$line"
        check_command "Command failed: $line"
    done < "$COMMAND_FILE"

    log "All commands executed successfully."
}

# Function to setup DataPusher
setup_datapusher() {
    if [[ $CKAN__PLUGINS == *"datapusher"* ]]; then
        if [ -z "$CKAN__DATAPUSHER__API_TOKEN" ] ; then
            log "Set up ckan.datapusher.api_token in the CKAN config file"
            api_token=$(ckan -c "$CKAN_INI" user token add ckan_admin datapusher | tail -n 1 | tr -d '\t')
            add_config "ckan.datapusher.api_token" "$api_token"
        fi
    else
        log "Not configuring DataPusher"
    fi
}

# Function to watch for changes and sync
watch_sync() {
    while true; do
        sync_extensions
        sleep 5
    done
}

# Main execution
main() {
    log "Starting Docker entrypoint script"

    # Setup DataPusher
    setup_datapusher

    # Apply configurations
    if [ -n "$INI_CONFIG_LINES" ]; then
        apply_configs_from_file "$INI_CONFIG_LINES"
    else
        log "INI_CONFIG_LINES not set, skipping configuration application"
    fi

    # Install requirements and sync extensions
    install_requirements
    sync_extensions
    install_all_extensions

    # Execute commands from file
    execute_commands_from_file

    # Start watching for changes in background
    watch_sync &

    log "Docker entrypoint script completed successfully"
}

# Run the main function
main