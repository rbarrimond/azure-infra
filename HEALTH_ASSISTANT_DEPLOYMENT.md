# Health Assistant Infrastructure Deployment Guide

**Status**: ✅ Infrastructure code complete - Ready for deployment

## Overview

Your health assistant now has a complete Terraform infrastructure module that provisions:

- **Azure Storage Account** (dedicated for health data - separate from core infra)
- 5 Table Storage tables: `Workouts`, `WeeklyRollups`, `IngestionState`, `Physiometrics`, `OneDriveTokens`
  - Blob container for read-only backups with automatic lifecycle management
    - Moves to cool tier after 30 days
    - Deletes after 90 days
- **Azure Functions** (Python 3.13, consumption plan)
  - HTTP endpoint and timer for OneDrive Personal sync (Microsoft Graph)
  - Daily timer trigger (2 AM UTC) for automated backups
  - Managed Identity for secure Key Vault access (no connection strings in config)
  - Application Insights integration for monitoring
- **DNS CNAME** (`health.azure.barrimond.net`) pointing to Function App
- **Key Vault Secrets** for Withings API credentials

## Deployment Steps

### 1. Deploy Infrastructure with Terraform

```bash
cd /Users/robertbarrimond/Developer/azure-infra

# Review the plan
terraform plan -var-file=terraform.tfvars

# Deploy (requires Azure login)
az login
terraform apply -var-file=terraform.tfvars
```

Expected resources:

- 13 new resources (storage account, tables, function app, etc.)
- 1 modification (tag cleanup on therobvault function)

**Deployment time**: ~3-5 minutes

### 2. Deploy Function App Code

Once Terraform completes, deploy the Python code:

```bash
cd /Users/robertbarrimond/Developer/health_assistant

# Install production dependencies
pip install -r requirements.txt

# Package and deploy to Azure
func azure functionapp publish func-healthassistant-prod-xxxx --build remote

# Verify deployment
curl https://health.azure.barrimond.net/api/health
# Expected: {"status": "healthy"}
```

### 3. Authorize OneDrive Personal

1. Create a Microsoft app registration (consumer accounts enabled)
2. Set redirect URI to: `https://health.azure.barrimond.net/api/onedrive/callback`
3. Store `ONEDRIVE_CLIENT_ID` and `ONEDRIVE_CLIENT_SECRET` in app settings
4. Authorize via: `https://health.azure.barrimond.net/api/onedrive/authorize?athlete_id=rob`

Note: Delegated permissions are granted by the user during the browser consent step; no pre-grant is required in Terraform for this flow.

### 4. Configure Withings Integration (Optional)

If using Withings for physiometrics:

```bash
# Authorize Withings OAuth
curl https://health.azure.barrimond.net/api/withings/authorize

# This redirects to Withings login, then returns callback to:
# https://health.azure.barrimond.net/api/withings/callback

# The tokens are automatically stored in Key Vault
```

## Architecture Summary

```text
┌─────────────────────────────────────────────────────────────────┐
│                    OneDrive (/Apps/HealthFit)                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│          Microsoft Graph OAuth (delegated refresh token)         │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│          Azure Functions: health.azure.barrimond.net            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ HTTP Triggers:                                           │  │
│  │ • POST /api/process_fit  (FIT file upload)              │  │
│  │ • POST /api/onedrive/sync (OneDrive sync)               │  │
│  │ • GET /api/workouts      (query workouts)               │  │
│  │ • GET /api/planning/context  (planning data)            │  │
│  │ • GET /api/withings/callback (OAuth callback)           │  │
│  │                                                          │  │
│  │ Timer Triggers:                                          │  │
│  │ • Backup Export (daily 2 AM UTC)                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Identity: System-assigned Managed Identity                    │
│  (reads Withings tokens from Key Vault)                        │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│         Azure Storage Account (dedicated for health data)       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Table Storage:                                           │  │
│  │ • Workouts (100+ fields per session)                    │  │
│  │ • WeeklyRollups (aggregated metrics)                    │  │
│  │ • IngestionState (idempotency tracking)                 │  │
│  │ • Physiometrics (body metrics from Withings)            │  │
│  │                                                          │  │
│  │ Blob Storage (backups):                                 │  │
│  │ • JSON exports (daily 2 AM UTC)                         │  │
│  │ • Organized by date: backups/YYYY-MM-DD/HH-MM-SSZ.json │  │
│  │ • Cool tier after 30 days, deleted after 90 days       │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                Read Interfaces (future)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • Power BI (training analytics dashboards)             │  │
│  │ • Application Insights (function health monitoring)    │  │
│  │ • ChatGPT Plugin (conversational planning)              │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

## Monitoring & Observability

### Application Insights (built-in)

Automatically logs:

- Function execution metrics (duration, invocation count, errors)
- Cold start overhead (consumption plan)
- Dependency calls (Table Storage, Key Vault)

View in Azure Portal:

```text
Resource Group: rg-core-prod-xxxx
Resource: appi-core-prod-xxxx (Application Insights)
```

### Daily Backup Logs

Check backup export success/failure:

```bash
# View last 10 backups in blob storage
az storage blob list \
  --account-name sthealthprodxxxx \
  --container-name backups \
  --num-results 10
```

### Manual Backup Trigger

To manually trigger a backup export:

```bash
curl -X POST https://health.azure.barrimond.net/api/backup/export \
  -H "Content-Type: application/json" \
  -d '{"force": true}'
```

## Scaling Strategy

### Current Setup (Cost-Optimized for Single User)

- **Function App**: Consumption plan
  - Scales to 0 when idle
  - First request may experience 2-3 second cold start
  - Cost: ~$0.20/million executions + storage costs
- **Storage**: Standard LRS (Local Redundant)
  - Cost: ~$0.02 per GB/month + transaction costs
- **Backup Lifecycle**: Cool tier after 30 days
  - Reduces storage cost by ~50% for older backups

### Scaling Path (If Needed)

1. **Add multiple athletes**:
   - Function app scales automatically
   - Consider adding Application Insights alert on error rate
   - May need Table Storage partitioning strategy

2. **Real-time analytics**:
   - Add Event Grid trigger (optional replacement for timer polling)
   - Migrate Table Storage → Cosmos DB for hierarchical partition keys

3. **High-frequency queries**:
   - Upgrade to Premium plan (always-on to avoid cold starts)
   - Add Azure Cache for Redis

## Cost Estimate (Monthly)

| Resource | Estimate | Notes |
| -------- | -------- | ----- |
| Functions | $0.50 | ~200k executions/month |
| Storage Account | $0.50 | ~2-5 GB + transactions |
| Application Insights | $0 | Included in core quota |
| Key Vault | $0.40 | ~1 secret + operations |
| **Total** | **~$1.40** | Minimal for single athlete |

## Troubleshooting

### Function App Won't Start

```bash
# Check logs
az functionapp log tail -n 100 \
  --resource-group rg-core-prod-xxxx \
  --name func-healthassistant-prod-xxxx
```

### Table Storage Queries Failing

- Verify `AzureWebJobsStorage` environment variable is set
- Check Managed Identity has secret read permissions in Key Vault
- Tables are auto-created on first Function App startup

### Backup Export Fails

- Check Function App logs (see above)
- Verify `backups` container exists in storage account
- Ensure Function App Managed Identity has Blob Contributor role

### OneDrive OAuth Issues

- Verify redirect URI matches `https://health.azure.barrimond.net/api/onedrive/callback`
- Ensure app registration supports personal Microsoft accounts
- Confirm client ID/secret are set in Function App settings

## Next Steps

1. **Deploy infrastructure**: `terraform apply`
2. **Deploy function code**: `func azure functionapp publish`
3. **Authorize OneDrive**: Complete OAuth flow
4. **Test ingestion**: Run `POST /api/onedrive/sync`
5. **Monitor first backup**: Check logs at 2 AM UTC tomorrow
6. **Add Power BI dashboards**: Query table storage for analytics

## Files Modified

### Infrastructure (azure-infra/)

- `main.tf`: Added health-assistant module call
- `variables.tf`: Added Withings credential variables
- `modules/health-assistant/main.tf`: 140 lines (storage, function, tables, lifecycle)
- `modules/health-assistant/variables.tf`: 72 lines (inputs)
- `modules/health-assistant/outputs.tf`: 42 lines (outputs)

### Application (health_assistant/)

- `function_app.py`: Added backup timer trigger + import
- `FitParser/backup_exporter.py`: New 155-line module for backup export

### Total Changes

- **Terraform**: 3 new files (~250 lines)
- **Python**: 1 new module, 1 updated file (~170 lines)
- **Validation**: ✅ Terraform valid, ✅ Python syntax valid
- **Plan**: 13 resources to create, 1 to update

---

**Questions?** Review the architecture docs:

- [WORKOUT_INTELLIGENCE_AGENT_VISION.md](../health_assistant/WORKOUT_INTELLIGENCE_AGENT_VISION.md) - System design
- [SEMANTIC_LAYER_API.md](../health_assistant/SEMANTIC_LAYER_API.md) - API endpoints
- [WORKOUT_SCHEMA.md](../health_assistant/WORKOUT_SCHEMA.md) - Data model
