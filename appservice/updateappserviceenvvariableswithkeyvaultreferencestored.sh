#!/bin/bash

# -------- CONFIGURE THESE -------- #
RESOURCE_GROUP="<resource-group-name>"
APP_SERVICE_NAME="<app-service-name>"
KEYVAULT_NAME="<keyvault-name>"
# -------------------------------- #

# Extra excluded app settings 
EXCLUDE_SETTINGS=(
  "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"
  "APPINSIGHTS_INSTRUMENTATIONKEY"
  "APPINSIGHTS_PROFILERFEATURE_VERSION"
  "APPLICATIONINSIGHTS_CONNECTION_STRING"
  "ApplicationInsightsAgent_EXTENSION_VERSION"
  "ASPNETCORE_ENVIRONMENT"
  "DIAGNOSTICS_AZUREBLOBCONTAINERSASURL"
  "DIAGNOSTICS_AZUREBLOBRETENTIONINDAYS"
  "DiagnosticServices_EXTENSION_VERSION"
  "InstrumentationEngine_EXTENSION_VERSION"
  "SnapshotDebugger_EXTENSION_VERSION"
  "WEBSITE_HTTPLOGGING_RETENTION_DAYS"
  "WEBSITE_RUN_FROM_PACKAGE"
  "XDT_MicrosoftApplicationInsights_BaseExtensions"
  "XDT_MicrosoftApplicationInsights_Java"
  "XDT_MicrosoftApplicationInsights_Mode"
  "XDT_MicrosoftApplicationInsights_NodeJS"
  "XDT_MicrosoftApplicationInsights_PreemptSdk"
)

is_excluded() {
  local key="$1"
  for ex in "${EXCLUDE_SETTINGS[@]}"; do
    if [[ "$key" == "$ex" ]]; then
      return 0
    fi
  done
  return 1
}

echo "Fetching App Service app settings..."
APP_SETTINGS_JSON=$(az webapp config appsettings list \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    -o json)

echo "Updating App Service settings with Key Vault references..."
echo "---------------------------------------------------------------"

echo "$APP_SETTINGS_JSON" | jq -r '.[] | "\(.name)\t\(.value)"' | while IFS=$'\t' read -r name value; do

    # Skip Azure internal variables
    if [[ "$name" == WEBSITE* ]] || [[ "$name" == XDT* ]] || [[ "$name" == APPINSIGHTS* ]]; then
        continue
    fi

    # Skip additional excluded variables
    if is_excluded "$name"; then
        echo "Skipping excluded setting: $name"
        continue
    fi

    # Generate cleaned name (same logic as Step 1)
    cleaned_name=$(echo "$name" | tr -d '_:')

    echo "Processing setting: $name (secret: $cleaned_name)"

    # Retrieve secret URI from Key Vault
    SECRET_URI=$(az keyvault secret show \
        --vault-name "$KEYVAULT_NAME" \
        --name "$cleaned_name" \
        --query "id" -o tsv 2>/dev/null)

    # Validate secret
    if [[ -z "$SECRET_URI" ]]; then
        echo "Secret not found in Key Vault: $cleaned_name — Skipping."
        continue
    fi

    # Build Key Vault reference string
    KV_REF="@Microsoft.KeyVault(SecretUri=$SECRET_URI)"

    echo "Updating App Setting: $name Key Vault Reference"
    echo "    $KV_REF"

    # Update App Setting
    # Uncomment when ready:
    az webapp config appsettings set \
        --resource-group "$RESOURCE_GROUP" \
        --name "$APP_SERVICE_NAME" \
        --settings "$name=$KV_REF" >/dev/null

    echo "Updated: $name"
    echo "---------------------------------------------------------------"

done

echo "All applicable App Service settings updated to KeyVault references!"

# To load appservice env variables in keyvault, please look for https://github.com/yateeshchaturvedi/Automation-scripts/blob/main/keyvault/addsecretfromappservice.sh
