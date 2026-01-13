# azure-infra

Infrastructure as Code repository for managing personal Azure cloud infrastructure. This codebase provisions and maintains cloud resources for multiple interconnected projects using Terraform and Azure Pipelines.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup & Deployment](#setup--deployment)
- [Environment Configuration](#environment-configuration)
- [CI/CD Pipeline](#cicd-pipeline)
- [Outputs](#outputs)

## Overview

This repository manages Azure infrastructure for the following projects:

- **Baldwin**: Static website deployment powered by Azure Static Web Apps
- **The Rob Vault**: Destiny 2 vault backend service with Function App and SQL Database integration
- **Core Infrastructure**: Shared services including networking, storage, security, and monitoring

### Key Azure Services

- **Azure Static Web Apps**: Hosting for Baldwin static site
- **Azure Function Apps**: Backend APIs for The Rob Vault (Python runtime)
- **Azure SQL Database**: Serverless SQL database for vault data
- **Azure Storage Account**: Blob storage with static website hosting
- **Azure Key Vault**: Secrets management for API keys and credentials
- **Azure App Service Plan**: Hosting compute for function apps
- **Azure DNS Zone**: Custom domain management (azure.barrimond.net)
- **Azure Application Insights**: Monitoring and diagnostics
- **Azure Cognitive Services**: OpenAI integration for GPT-4 deployment

## Architecture

### Module Structure

```plaintext
modules/
├── core/                 # Shared infrastructure foundation
│   ├── main.tf          # Resource Group, Storage, DNS, Key Vault, SQL Server
│   ├── autoscale.tf     # Auto-scaling configuration
│   ├── outputs.tf       # Core module outputs
│   └── variables.tf     # Input variables
├── baldwin/             # Static website deployment
│   ├── main.tf          # Static Web App, Function App, DNS records
│   └── variables.tf     # Configuration variables
└── the_rob_vault/       # Vault backend service
    ├── main.tf          # SQL Database, Function App, secrets management
    ├── outputs.tf       # Service outputs
    └── variables.tf     # Configuration variables
```

### Core Module

Provisions the foundational infrastructure:

- Resource Group for resource organization
- Storage Account with static website hosting ($web container)
- DNS Zone for custom domain management (azure.barrimond.net)
- Key Vault for secrets and certificates
- SQL Server (serverless architecture ready)
- App Service Plan (B2 SKU) for hosting function apps
- Log Analytics Workspace and Application Insights for monitoring
- RBAC assignments for GitHub Actions service principal

### Baldwin Module

Deploys a static website with the following components:

- Azure Static Web Apps for fast, secure static content delivery
- DNS CNAME record pointing to the Static Web App
- Custom domain binding
- Storage Account for additional blob storage needs
- Linux Function App with Python runtime for backend APIs
- Application Insights integration

### The Rob Vault Module

Provisions a serverless backend service:

- Serverless SQL Database (auto-pause after 60 minutes of inactivity)
- Managed database with Key Vault integration
- Linux Function App (Python) for API endpoints
- Bungie API integration with credentials stored in Key Vault
- Custom DNS records for FQDN routing
- Diagnostic logging and monitoring
- Cognitive Services deployment for LLM-powered features (GPT-4.1-nano)

## Prerequisites

### Required Software

- **Terraform** >= 1.3.0
- **Azure CLI** (authenticated and connected to your subscription)
- **Azure subscription** with appropriate permissions

### Required Permissions

- Contributor or Owner role on the subscription
- Ability to create and manage Azure AD service principals
- Access to Azure DNS zone administration (azure.barrimond.net)

### Infrastructure Requirements

- **Azure Storage Account** for Terraform state (remote backend)
  - Container: `terraform`
  - State file key: `core/terraform.tfstate`
- **GitHub Actions Service Principal** configured with:
  - Client ID: Used for CI/CD deployments
  - Storage Blob Data Contributor role

### Secrets & Credentials

The following sensitive values are required as variables (defined in tfvars files):

- `subscription_id`: Azure subscription ID
- `tenant_id`: Azure AD tenant ID
- `github_token`: GitHub personal access token for repository cloning
- `bungie_client_id`: Bungie API client ID
- `bungie_client_secret`: Bungie API client secret
- `bungie_redirect_uri`: OAuth redirect URI for Bungie authentication
- `bungie_api_key`: Bungie API key
- `key_vault_admin_object_id`: Azure AD object ID for Key Vault admin
- `github_actions_sp_client_id`: GitHub Actions service principal client ID

## Project Structure

```plaintext
azure-infra/
├── main.tf                          # Root module - orchestrates child modules
├── variables.tf                     # Root input variables
├── outputs.tf                       # Root outputs (all module outputs)
├── backend.tf                       # Remote state configuration (Azure Storage)
├── terraform.tfvars                 # Production variable values
├── azure-pipelines.yml              # CI/CD pipeline configuration
├── modules/
│   ├── core/                        # Core infrastructure module
│   ├── baldwin/                     # Static website module
│   └── the_rob_vault/              # Vault backend service module
├── environments/
│   ├── dev.tfvars.sample           # Dev environment template
│   ├── dev.tfvars                  # Dev environment values (not committed)
│   ├── prod.tfvars.sample          # Prod environment template
│   └── prod.tfvars                 # Prod environment values (not committed)
└── static/
    ├── index.html                   # Static website homepage
    └── 404.html                     # Error page
```

## Setup & Deployment

### 1. Initialize Terraform

```bash
cd /path/to/azure-infra
terraform init
```

This initializes Terraform and configures the remote backend (Azure Storage).

### 2. Create Environment Variables File

Copy the sample file and fill in your values:

```bash
cp environments/prod.tfvars.sample environments/prod.tfvars
# Edit with your actual values
nano environments/prod.tfvars
```

### 3. Plan Deployment

Review planned changes before applying:

```bash
# For production
terraform plan -var-file="terraform.tfvars"

# For a specific environment
terraform plan -var-file="environments/prod.tfvars"
```

### 4. Apply Configuration

Deploy infrastructure to Azure:

```bash
# For production
terraform apply -var-file="terraform.tfvars"

# For a specific environment
terraform apply -var-file="environments/prod.tfvars"
```

### 5. Verify Deployment

After successful deployment, verify outputs:

```bash
terraform output
```

## Environment Configuration

### Development Environment

Use `environments/dev.tfvars` for development deployments. This typically includes:

- Smaller Azure SKUs for cost optimization
- Shorter auto-pause delays for serverless resources
- Development-tagged resources

Example:

```hcl
subscription_id             = "your-dev-subscription-id"
tenant_id                   = "your-tenant-id"
region                      = "eastus2"
environment                 = "dev"
key_vault_admin_object_id   = "your-dev-admin-object-id"
github_actions_sp_client_id = "your-sp-client-id"
# ... (other variables)
```

### Production Environment

Use `terraform.tfvars` (or `environments/prod.tfvars`) for production deployments. Includes:

- Standard/Premium SKUs for performance
- Enhanced monitoring and diagnostics
- Production-tagged resources
- Longer auto-pause delays

**Note**: Never commit actual tfvars files with secrets to version control. Use Azure Key Vault or secure configuration management.

## CI/CD Pipeline

### Azure Pipelines

The `azure-pipelines.yml` workflow:

1. **Triggers**: Automatically runs on changes to the `main` branch
2. **Authentication**: Uses Azure Service Connection (`azure-infra`)
3. **Static File Upload**: Deploys static website files to the storage account's `$web` container

#### Pipeline Steps

```yaml
- Azure CLI Login: Authenticate to Azure subscription
- Set Variables: Configure storage account name and file directory
- Upload Files: Push static files to $web container using `az storage blob upload-batch`
```

#### How It Works

- Runs on: Ubuntu latest
- Uploads files from `static/` directory to `$web` container
- Storage account: `stcoreprod59o7` (production)
- Access method: Azure CLI with managed identity

### Local Deployment

For local testing without CI/CD:

```bash
# Build the infrastructure
terraform apply -var-file="terraform.tfvars"

# Manually upload static files
az storage blob upload-batch \
  --account-name stcoreprod59o7 \
  --destination '$web' \
  --source ./static \
  --auth-mode login
```

## Outputs

After deployment, Terraform exports the following outputs:

### Core Infrastructure Outputs

- `core_resource_group_name`: Name of the shared resource group
- `core_storage_account_name`: Storage account for static hosting
- `core_static_website_url`: Primary static website endpoint
- `core_dns_zone_name`: DNS zone for custom domains
- `core_key_vault_name`: Key Vault for secrets management
- `core_app_service_plan_id`: App Service Plan resource ID
- `core_key_vault_id`: Key Vault resource ID
- `core_application_insights_workspace_id`: Application Insights workspace
- `core_sql_server_url`: SQL Server FQDN (serverless database host)

### The Rob Vault Outputs

- `the_rob_vault_function_app_name`: Function App name
- `the_rob_vault_function_app_fqdn`: Function App fully qualified domain name
- `the_rob_vault_custom_fqdn`: Custom domain FQDN
- `the_rob_vault_db_name`: SQL database name

View all outputs:

```bash
terraform output
```

View a specific output:

```bash
terraform output core_storage_account_name
terraform output the_rob_vault_function_app_fqdn
```

## Terraform State Management

### Remote State

State is stored in Azure Storage Account (`sabarrimond01`):

- **Container**: `terraform`
- **State Key**: `core/terraform.tfstate`
- **Resource Group**: `base`

This enables:

- Shared state across team members
- State locking to prevent concurrent modifications
- Centralized backup and recovery

### Local State Warning

The `errored.tfstate` file is a backup of a previously failed deployment and should not be used directly.

## Troubleshooting

### State Lock Issues

If you encounter state locking errors:

```bash
# View lock information
terraform force-unlock <LOCK_ID>
```

### Authentication Errors

Ensure Azure CLI is authenticated:

```bash
az login
az account set --subscription "<subscription-id>"
```

### Resource Already Exists

If Terraform reports a resource already exists:

```bash
# Import the resource into state
terraform import <resource_type>.<resource_name> <azure_resource_id>
```

## Related Projects

- **baldwin-static**: Static website repository (deployed via Baldwin module)
- **the-rob-vault-app**: Vault backend application (deployed via The Rob Vault module)
