#!/bin/bash

# Define the output CSV file
OUTPUT_FILE="outbound_ips.csv"

# Write the CSV header
echo "AppServiceName,ResourceGroup,OutboundIPs" > $OUTPUT_FILE

# List of web apps (format: "<resource-group-name> <app-service-name>")
WEBAPPS=(
    "Resource-Group-Name AppService-Name"
)

# Loop through the web apps and fetch outbound IPs
for WEBAPP in "${WEBAPPS[@]}"; do
    RESOURCE_GROUP=$(echo $WEBAPP | awk '{print $1}')
    APP_SERVICE=$(echo $WEBAPP | awk '{print $2}')

    # Fetch outbound IPs
    OUTBOUND_IPS=$(az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_SERVICE" --query outboundIpAddresses --output tsv 2>/dev/null)

    # Check if the command succeeded
    if [ $? -eq 0 ]; then
        # Append the data to the CSV file
        echo "$APP_SERVICE,$RESOURCE_GROUP,\"$OUTBOUND_IPS\"" >> $OUTPUT_FILE
    else
        # Log an error if the command failed
        echo "$APP_SERVICE,$RESOURCE_GROUP,ERROR_FETCHING_IPS" >> $OUTPUT_FILE
    fi
done

# Print a completion message
echo "Outbound IPs have been saved to $OUTPUT_FILE"
