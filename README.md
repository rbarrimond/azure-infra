# azure-infra

Infrastructure-as-code for personal Azure resources. This repo provisions shared core services plus project-specific stacks using Terraform and supports both GitHub Actions OIDC and Azure Pipelines for static site deployments.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup & Deployment](#setup--deployment)
- [Environment Configuration](#environment-configuration)
- [CI/CD](#cicd)
- [Terraform State](#terraform-state)
- [Outputs](#outputs)
- [Troubleshooting](#troubleshooting)
- [Related Docs](#related-docs)

## Overview

Projects managed in this repo:

- **Baldwin**: Static website + supporting Function App
- **The Rob Vault**: Destiny 2 vault backend (Function App + SQL DB + Azure OpenAI deployment)
- **Health Assistant**: Health data ingestion and analytics (Function App + Storage tables + OneDrive + Withings integrations)
- **Core Infrastructure**: Shared services (resource group, storage, DNS, Key Vault, monitoring, OpenAI account)

Key Azure services used:

- Azure Resource Group, Storage Account (static website hosting)
- Azure DNS Zone (`azure.barrimond.net`)
- Azure Key Vault
- Azure Log Analytics + Application Insights
- Azure App Service Plans (B2 in core, B1 dedicated for Health Assistant)
- Azure Function Apps (Linux)
- Azure SQL Server + serverless database (The Rob Vault)
- Azure OpenAI (Cognitive Services) account + deployment
- Microsoft Entra ID app registrations for GitHub Actions OIDC and optional OneDrive OAuth

## Architecture

### Modules

```plaintext
modules/
├── core/               # Shared foundation (RG, Storage, DNS, Key Vault, SQL Server, AI)
├── baldwin/            # Static Web App + Function App + DNS
├── the_rob_vault/      # SQL DB + Function App + DNS + AI deployment
└── health-assistant/   # Storage tables + Function App + DNS + integrations
```

### Core Module

Provisioned resources:

- Resource group
- Storage account configured for static website hosting (`$web` container)
- DNS zone (`azure.barrimond.net`) + `static` CNAME for the storage website endpoint
- Key Vault with admin access policy and SQL admin secrets
- Linux App Service plan (B2)
- Log Analytics workspace + Application Insights
- Azure SQL Server (no DB in core)
- Azure OpenAI (Cognitive Services) account

### Baldwin Module

Provisioned resources:

- Azure Static Web App (Standard)
- CNAME + custom domain binding (`baldwin.azure.barrimond.net`)
- Storage account for app assets
- Linux Function App (Python 3.11)
- Static Web App -> Function App registration

### The Rob Vault Module

Provisioned resources:

- Serverless Azure SQL Database (GP_S_Gen5_1, auto-pause 60 mins)
- Storage account
- Key Vault secrets for Bungie credentials and storage connection string
- Linux Function App (Python 3.10) with Key Vault secret references
- CNAME + custom domain + managed TLS (`therobvault.azure.barrimond.net`)
- Diagnostic settings to Log Analytics
- Azure OpenAI deployment (default: `gpt-4.1-nano`, version `2025-04-14`)

### Health Assistant Module

Provisioned resources:

- Dedicated storage account for health data
- Storage tables: `Workouts`, `WeeklyRollups`, `IngestionState`, `Physiometrics`, `OneDriveTokens`
- Backup blob container with lifecycle policy (cool tier after 30 days, delete after 90)
- Dedicated Linux App Service plan (B1)
- Linux Function App (Python 3.13)
- Key Vault secrets for Withings and OneDrive credentials
- CNAME + custom domain + managed TLS (`health.azure.barrimond.net`)

## Prerequisites

- **Terraform** >= 1.3.0
- **Azure CLI** authenticated to your subscription
- **Azure subscription** with permissions to create resources

Required permissions:

- Contributor or Owner on the subscription
- Access to manage the DNS zone `azure.barrimond.net`
- Ability to create Microsoft Entra ID app registrations

## Project Structure

```plaintext
azure-infra/
├── backend.tf                      # Remote state in Azure Storage
├── main.tf                         # Root module wiring
├── variables.tf                    # Root inputs
├── outputs.tf                      # Root outputs
├── terraform.tfvars                # Prod defaults (do not commit secrets)
├── azure-pipelines.yml             # Azure Pipelines static site deploy
├── .github/workflows/
│   └── deploy-static-site.yml      # GitHub Actions static site deploy
├── environments/
│   ├── dev.tfvars.sample
│   ├── prod.tfvars.sample
│   └── *.tfvars (not committed)
├── modules/
│   ├── core/
│   ├── baldwin/
│   ├── the_rob_vault/
│   └── health-assistant/
└── static/
  ├── assets/
  │   └── site.css
  ├── README.md
    ├── index.html
    └── 404.html
```

## Setup & Deployment

### 1. Initialize Terraform

```bash
cd /path/to/azure-infra
terraform init
```

### 2. Configure Variables

Create a tfvars file from the sample and populate values:

```bash
cp environments/prod.tfvars.sample environments/prod.tfvars
```

Required values include:

- `subscription_id`, `tenant_id`, `region`
- `key_vault_admin_object_id`
- `github_token` (for Baldwin Static Web App repo access)
- `bungie_client_id`, `bungie_client_secret`, `bungie_redirect_uri`, `bungie_api_key`
- Health Assistant defaults and OAuth values (Withings, OneDrive)

Optional values:

- `create_onedrive_app_registration` and `onedrive_redirect_uris` if Terraform should create the OneDrive app registration
- `github_actions_repo` and `github_actions_branch` to scope OIDC credentials

### 3. Plan

```bash
terraform plan -var-file="environments/prod.tfvars"
```

### 4. Apply

```bash
terraform apply -var-file="environments/prod.tfvars"
```

## Environment Configuration

- `environments/dev.tfvars` for dev deployments (smaller SKUs / dev tags)
- `environments/prod.tfvars` or `terraform.tfvars` for production

**Do not commit real tfvars files** with secrets. Store secrets in Key Vault or a secure secret manager.

## CI/CD

### GitHub Actions (OIDC)

Workflow: `.github/workflows/deploy-static-site.yml`

- Uses `azure/login@v2` with OIDC
- Uploads `static/` to the `$web` container in the core storage account
- Triggers on pushes to the `static` branch
- Requires GitHub secrets:
  - `AZURE_CLIENT_ID`
  - `AZURE_TENANT_ID`
  - `AZURE_SUBSCRIPTION_ID`

Terraform creates a GitHub Actions app registration and federated credential, and assigns `Storage Blob Data Contributor` to the core storage account. Outputs:

- `github_actions_oidc_client_id`
- `github_actions_oidc_app_name`

Reference: `GITHUB_ACTIONS_OIDC.md` for setup details and naming conventions.

### Azure Pipelines

Pipeline: `azure-pipelines.yml`

- Logs in with an Azure service connection
- Uploads `static/` to the `$web` container
- Targets `stcoreprod59o7`

## Terraform State

State is stored in Azure Storage (see `backend.tf`):

- Resource Group: `base`
- Storage Account: `sabarrimond01`
- Container: `terraform`
- Key: `core/terraform.tfstate`

`errored.tfstate` is a backup of a failed deployment and should not be used directly.

## Outputs

Core outputs:

- `core_resource_group_name`
- `core_storage_account_name`
- `core_static_website_url`
- `core_dns_zone_name`
- `core_key_vault_name`
- `core_app_service_plan_id`
- `core_key_vault_id`
- `core_application_insights_workspace_id`
- `core_sql_server_url`

OIDC outputs:

- `github_actions_oidc_client_id`
- `github_actions_oidc_app_name`

The Rob Vault outputs:

- `the_rob_vault_function_app_name`
- `the_rob_vault_function_app_fqdn`
- `the_rob_vault_custom_fqdn`
- `the_rob_vault_db_name`

Health Assistant outputs:

- `health_assistant_function_app_name`
- `health_assistant_function_app_default_hostname`
- `health_assistant_api_endpoint`
- `health_assistant_storage_account_name`
- `health_assistant_function_app_id`
- `health_assistant_function_app_identity_principal_id`
- `health_assistant_custom_hostname`
- `health_assistant_managed_certificate_id`
- `health_assistant_healthcheck_url`

View outputs:

```bash
terraform output
terraform output health_assistant_api_endpoint
```

## Troubleshooting

State lock issues:

```bash
terraform force-unlock <LOCK_ID>
```

Authentication issues:

```bash
az login
az account set --subscription "<subscription-id>"
```

Resource already exists:

```bash
terraform import <resource_type>.<resource_name> <azure_resource_id>
```

## Related Docs

- `GITHUB_ACTIONS_OIDC.md`
- `HEALTH_ASSISTANT_DEPLOYMENT.md`
