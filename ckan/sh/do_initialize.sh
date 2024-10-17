#!/bin/bash

# Set variables
ORG_NAME="Vuhitra"
ORG_ID="vuhitra-io"
ORG_DESCRIPTION="Home Dev"
USER_NAME="ckan_admin"
TOKEN_NAME="default-token"
TOKEN_VALUE="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIyeC1lUHhvXzNrdVgxQlE4Nzlsb3lWOTRYSTZhT2o1OGVKSHBNQnppN0dzIiwiaWF0IjoxNzI5MTUyNzQzfQ.SNQ-E2YHZvUMEpt1LkNbRJfLI8L0WRn7q4XEGeGu1OU"

# Ensure CKAN_INI is set
if [ -z "$CKAN_INI" ]; then
    CKAN_INI="/srv/app/ckan.ini"
    echo "CKAN_INI not set, using default: $CKAN_INI"
fi

# Create the organization (using dataset command)
echo "Creating organization..."
docker exec -it ckan-dev ckan -c "$CKAN_INI" dataset create-org \
    name="$ORG_ID" \
    title="$ORG_NAME" \
    description="$ORG_DESCRIPTION"

# Create the API token
echo "Creating API token..."
docker exec -it ckan-dev ckan -c "$CKAN_INI" user token add \
    "$USER_NAME" \
    "$TOKEN_NAME" \
    --json "{\"token\": \"$TOKEN_VALUE\"}"

# Verify the organization was created (using group command)
echo "Verifying organization..."
docker exec -it ckan-dev ckan -c "$CKAN_INI" group show "$ORG_ID"

# Verify the token was created (this will only show the token name, not the value)
echo "Verifying token..."
docker exec -it ckan-dev ckan -c "$CKAN_INI" user token list "$USER_NAME"

echo "Initialization complete."