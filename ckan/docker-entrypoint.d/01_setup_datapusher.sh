#!/bin/bash

if [[ $CKAN__PLUGINS == *"datapusher"* ]]; then
   # Datapusher settings have been configured in the .env file
   # Set API token if necessary
   if [ -z "$CKAN__DATAPUSHER__API_TOKEN" ] ; then
      echo "Set up ckan.datapusher.api_token in the CKAN config file"
      ckan config-tool $CKAN_INI "ckan.datapusher.api_token=$(ckan -c $CKAN_INI user token add ckan_admin datapusher | tail -n 1 | tr -d '\t')"
   fi
else
   echo "Not configuring DataPusher"
fi


add_config() {
    local key="$1"
    local value="$2"

    echo "Setting $key in CKAN config file"
    ckan config-tool "$CKAN_INI" "$key=$value"
}

# Check if scheming plugin is enabled
if [[ $CKAN__PLUGINS == *"scheming_datasets"* ]]; then
    echo "Configuring scheming plugin"

    # Add scheming dataset schemas
    add_config "scheming.dataset_schemas" "ckanext.zarr.schemas:dcat_dublin.yaml"

    # Add scheming presets
    add_config "scheming.presets" "ckanext.scheming:presets.json ckanext.zarr:presets.json"
else
    echo "Scheming plugin is not enabled, skipping configuration"
fi

echo "Scheming configuration complete"
