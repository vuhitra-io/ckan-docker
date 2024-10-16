#!/bin/bash


## Check if the lines file exists
#if [ ! -f "$INI_CONFIG_LINES" ]; then
#    echo "Error: $INI_CONFIG_LINES does not exist."
#    exit 1
#fi
#
## Read each line from the file and add it to ckan.ini if it doesn't exist
#while IFS= read -r line
#do
#    echo -e "\n" >> "$CKAN_INI"
#    if ! grep -qF "$line" "$CKAN_INI"; then
#        echo "$line" >> "$CKAN_INI"
#        echo "Added: $line"
#    else
#        echo "Skipped (already exists): $line"
#    fi
#done < "$INI_CONFIG_LINES"
#
#echo "CKAN ini additional configs added."