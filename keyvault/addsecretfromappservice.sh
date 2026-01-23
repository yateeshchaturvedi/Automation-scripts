#!/bin/bash

# -------- CONFIGURE THESE -------- #
RESOURCE_GROUP="<resource-group-name>"
APP_SERVICE_NAME="<app-service-name>"
KEYVAULT_NAME="<keyvault-name>"
# -------------------------------- #

echo "Fetching environment variables for App Service: $APP_SERVICE_NAME ..."
echo "---------------------------------------------------------------"

# Fetch settings as JSON
APP_SETTINGS_JSON=$(az webapp config appsettings list \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_SERVICE_NAME" \
  -o json)

echo "CLEANED_NAME = VALUE"
echo "---------------------------------------------------------------"

# Loop through JSON and filter out Azure-internal variables
echo "$APP_SETTINGS_JSON" | jq -r '.[] | "\(.name)\t\(.value)"' | while IFS=$'\t' read -r name value; do

    # Skip Azure-internal variables
    if [[ "$name" == WEBSITE* ]] || [[ "$name" == XDT* ]] || [[ "$name" == APPINSIGHTS* ]]; then
        continue
    fi

    # Remove _ and : from the variable name only
    cleaned_name=$(echo "$name" | tr -d '_:')

    # Print cleaned name with original value
    echo "$cleaned_name = $value"

    # Upload to Key Vault
    az keyvault secret set \
        --vault-name "$KEYVAULT_NAME" \
        --name "$cleaned_name" \
        --value "$value" \
        >/dev/null 2>&1

    echo "Uploaded: $cleaned_name"

done

echo "---------------------------------------------------------------"
echo "Clean output generated successfully (Azure-internal variables excluded) and uploaded to Keyvault."
