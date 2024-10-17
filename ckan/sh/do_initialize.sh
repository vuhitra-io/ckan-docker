#!/bin/bash

# Set variables
ORG_NAME="Vuhitra"
ORG_BASE_ID="vuhitra-io"
ORG_DESCRIPTION="Home Dev"
USER_NAME="admin"
USER_PASSWORD="Test.1234"
USER_EMAIL="admin@vuhitra.io"
TOKEN_NAME="default-token"
TOKEN_VALUE="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIyeC1lUHhvXzNrdVgxQlE4Nzlsb3lWOTRYSTZhT2o1OGVKSHBNQnppN0dzIiwiaWF0IjoxNzI5MTUyNzQzfQ.SNQ-E2YHZvUMEpt1LkNbRJfLI8L0WRn7q4XEGeGu1OU"


# Generate a random suffix (6 alphanumeric characters)
RANDOM_SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 6)

# Combine base ID with random suffix
ORG_ID="${ORG_BASE_ID}-${RANDOM_SUFFIX}"

echo "Generated Organization ID: $ORG_ID"

# Function to run commands inside the container
run_in_container() {
    docker exec -i ckan-dev bash -c "$1"
}

# Create admin user
echo "Creating admin user..."
user_create=$(run_in_container "ckan user add $USER_NAME email=$USER_EMAIL password=$USER_PASSWORD")
if echo "$user_create" | grep -q "User $USER_NAME created"; then
    echo "Admin user created successfully."
    run_in_container "ckan sysadmin add $USER_NAME"
    echo "Admin user granted sysadmin rights."
else
    echo "Note: Admin user might already exist. Proceeding with the script."
fi


# Function to check if token exists
check_token_exists() {
    local token_check=$(run_in_container "ckan -c \$CKAN_INI user token list '$USER_NAME' | grep '$TOKEN_NAME'")
    if [ -n "$token_check" ]; then
        echo "Token '$TOKEN_NAME' already exists for user '$USER_NAME'"
        TOKEN_VALUE=$(echo "$token_check" | awk '{print $NF}')
        return 0
    else
        return 1
    fi
}

# Check if token exists, if not, create it
if check_token_exists; then
    echo "Using existing token: $TOKEN_VALUE"
else
    echo "Creating API token..."
    TOKEN_VALUE=$(run_in_container "ckan -c \$CKAN_INI user token add '$USER_NAME' '$TOKEN_NAME' | tail -n 1 | tr -d '[:space:]'")
    echo "Token created: $TOKEN_VALUE"
fi

echo "Creating API token..."
TOKEN_VALUE=$(run_in_container "ckan -c \$CKAN_INI user token add '$USER_NAME' '$TOKEN_NAME' | tail -n 1 | tr -d '[:space:]'")
echo "Token created: $TOKEN_VALUE"

# Function to make API calls
make_api_call() {
    local endpoint="$1"
    local method="$2"
    local data="$3"
    run_in_container "curl -s -X $method http://localhost:5000/api/3/action/$endpoint \
        -H 'Authorization: $TOKEN_VALUE' \
        -H 'Content-Type: application/json' \
        -d '$data'"
}

# Create the organization
echo "Creating organization..."
org_data="{\"name\":\"$ORG_ID\",\"title\":\"$ORG_NAME\",\"description\":\"$ORG_DESCRIPTION\"}"
response=$(make_api_call "organization_create" "POST" "$org_data")
echo "$response"
if echo "$response" | grep -q '"success": true'; then
    echo "Organization created successfully."
fi


echo "Initialization complete."
