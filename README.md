# Azure Automation Scripts

This repository contains a collection of **automation scripts** for managing Azure resources and Azure DevOps configurations.  
The scripts are designed to reduce manual effort, improve consistency, and support operational and migration tasks across environments.

Scripts are grouped by Azure service for better organization and maintainability.

---

## Repository Structure

```
├── appservice/
│   ├── list-path-mounts.sh
│   ├── list-outbound-ips.sh
│   └── update-env-from-keyvault.sh
├── keyvault/
│   ├── upload-appservice-secrets.sh
│   └── migrate-keyvault-secrets.sh
├── azure-devops/
│   └── update-release-agentpool.sh
├── storage-account/
│   └── remove-files-from-fileshare-of-specific-extension.sh
└── README.md
```


> **Note:** Script names above are representative. Actual filenames may vary.

---

## appservice/

This directory contains scripts related to **Azure App Service** operations.

### List Path Mountings on App Services
- Lists all file system path mountings configured on Azure App Services.
- Useful for:
  - Auditing mounted storage
  - Debugging configuration issues
  - Reviewing App Service setup across environments

### List Outbound IP Addresses for App Services
- Fetches outbound IP addresses assigned to App Services.
- Useful for:
  - Firewall and network whitelisting
  - Third-party service integrations
  - Security reviews

### Update App Service Environment Variables Using Key Vault
- Updates App Service environment variables by referencing secrets stored in Azure Key Vault.
- Benefits:
  - Eliminates hardcoded secrets
  - Improves security and compliance
  - Centralized secret management

---

## keyvault/

This directory contains scripts for **Azure Key Vault** management.

### Upload App Service Secrets to Key Vault
- Extracts secrets or configuration values used by an App Service.
- Uploads them securely into Azure Key Vault.
- Useful for:
  - Secret centralization
  - Migrating legacy configurations
  - Improving security posture

### Migrate Secrets Between Key Vaults
- Copies secrets from one Azure Key Vault to another.
- Common use cases:
  - Environment migration (Dev → QA → Prod)
  - Subscription or tenant migration
  - Backup and recovery scenarios

---

## azure-devops/

This directory contains scripts for **Azure DevOps** automation.

### Update Agent Pool for Release Pipelines
- Updates the agent pool used by **release pipelines** created within a specific directory.
- Useful for:
  - Standardizing agent pools
  - Migrating from hosted to self-hosted agents
  - Infrastructure modernization

---

## Storage account/

This directory contains scripts for **Storage account** management.

### Remove specific file extensions from Azure file shares
- Extracts list of file share from storage account.
- List the files from file share
- Delete files with extensions set in script
- Useful for:
  - removing deprecated/useless files
  - List the files from storage account

---

## Prerequisites

Ensure the following tools are installed and configured before running any scripts:

- Bash (Linux / macOS / WSL)
- Azure CLI  
  ```bash
  az --version

## Usage

- Clone the repository:

  ```bash
  git clone https://github.com/yateeshchaturvedi/Automation-scripts.git
  cd Automation-scripts

  ```

- Navigate to the required directory:

  ```bash
  cd appservice

  ```

- Grant execute permission (if required):

  ```bash
  chmod +x script-name.sh

  ```

- Run the script:
  ```bash
  ./script-name.sh
  ```

Some scripts may require input parameters or environment variables.
Refer to comments inside each script for specific usage instructions.

> **Note:**

- Test scripts in non-production environments first.
- Review scripts before execution, especially those that:

  - Modify configurations
  - Update secrets
  - Impact CI/CD pipelines

- Validate outputs after execution, especially for:
  - Key Vault migrations
  - Environment variable updates
  - Azure DevOps pipeline changes

- Validate outputs after execution, especially for:
  - Key Vault migrations
  - Environment variable updates
  - Azure DevOps pipeline changes
