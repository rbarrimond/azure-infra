# GitHub Actions OIDC for Azure

This repository uses OpenID Connect (OIDC) for GitHub Actions authentication to Azure. OIDC avoids long-lived secrets by exchanging a short-lived token from GitHub for an Azure access token.

## Azure setup

1. Create or select an app registration (service principal) in Microsoft Entra ID.
2. Assign a role to the service principal at the right scope:
   - For static site uploads to a storage account: `Storage Blob Data Contributor`
   - Scope example: the storage account or resource group that hosts the $web container
3. Add a federated credential to the app registration:
   - Provider: GitHub Actions
   - Organization: `rbarrimond`
   - Repository: `azure-infra`
   - Entity type: `Branch`
   - Branch: `main`

## GitHub repository secrets

Add these secrets in the GitHub repo settings:

- `AZURE_CLIENT_ID` (Application/Client ID)
- `AZURE_TENANT_ID` (Directory/Tenant ID)
- `AZURE_SUBSCRIPTION_ID` (Subscription ID)

## Federated credential details guidance

Use consistent names and descriptions so credentials are easy to audit.

Name pattern:

`gha-<org>-<repo>-<environment>-<refType>-<refName>-<purpose>`

Examples:

- `gha-rbarrimond-azure-infra-prod-branch-main-deploy-storage`
- `gha-rbarrimond-azure-infra-dev-branch-feature-x-plan-terraform`

Description template:

`GitHub Actions OIDC for <org>/<repo> — <environment>, <refType>=<refName>, <purpose>. Scope: <scope>. Role: <role>.`

Example description:

`GitHub Actions OIDC for rbarrimond/azure-infra — prod, branch=main, deploy static site. Scope: /subscriptions/<subId>/resourceGroups/<rg>. Role: Storage Blob Data Contributor.`

## Workflow expectations

The workflow uses `azure/login@v2` with OIDC. It requires these permissions in the workflow:

- `id-token: write`
- `contents: read`

## Troubleshooting

- If login fails, confirm the federated credential matches the repo and branch.
- Ensure the role assignment scope includes the storage account used by the deployment.
- Verify the GitHub secrets map to the correct app registration and tenant.
