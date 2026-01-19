# Define variables
source_subscription="<source subscription_id>"
destination_subscription="<destination subscription_id>"
source_keyvault="<source keyvault name>"
destination_keyvault="<destination keyvault name>"

# List secrets from the source Key Vault
az account set --subscription "$source_subscription"

for secret_name in $(az keyvault secret list --vault-name "$source_keyvault" --query "[].name" -o tsv --subscription "$source_subscription"); do
    # Get secret value
    secret_value=$(az keyvault secret show --vault-name "$source_keyvault" --name "$secret_name" --query "value" -o tsv --subscription "$source_subscription")

    # Set the secret into destination Key Vault
    az keyvault secret set --vault-name "$destination_keyvault" --name "$secret_name" --value "$secret_value" --subscription "$destination_subscription"

    echo "Secret '$secret_name' copied successfully."
done
