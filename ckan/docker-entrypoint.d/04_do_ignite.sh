#!/bin/bash

# Check if the file exists
if [ ! -f "$COMMAND_FILE" ]; then
    echo "Error: File '$COMMAND_FILE' not found."
    touch $COMMAND_FILE
fi

# Copy the mounted file to a new location
cp $COMMAND_FILE /root/commands

# Set correct ownership and permissions for the new file
chown root:root /root/commands
chmod 644 /root/commands

COMMAND_FILE="/root/commands"

# Check if the file is owned by root and not writable by others
if [ "$(stat -c '%U' "$COMMAND_FILE")" != "root" ] || [ "$(stat -c '%a' "$COMMAND_FILE")" != "644" ]; then
    echo "Error: '$COMMAND_FILE' must be owned by root with permissions 644."
    exit 1
fi

# Read the file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim leading and trailing whitespace
    line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Skip empty lines and comments
    if [ -z "$line" ] || [[ "$line" == \#* ]]; then
        continue
    fi

    # Print the command being executed
    echo "Executing: $line"

    # Execute the command
    eval "$line"

    # Check the exit status
    if [ $? -ne 0 ]; then
        echo "Error: Command failed: $line"
        exit 1
    fi
done < "$COMMAND_FILE"

echo "All commands executed successfully."
