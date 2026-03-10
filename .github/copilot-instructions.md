# Copilot Constitution — Azure Infrastructure

This document governs how Copilot must behave when analyzing or modifying code in this repository.

This infrastructure-as-code system prioritizes **safety, predictability, and auditability** over convenience.

When in conflict, prefer infrastructure discipline.

---

## I. Azure Best Practices Are Mandatory

- @azure Rule - Use Azure Best Practices: When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your `azure_development-get_best_practices` tool if available.
- Always record code changes you make, and bump the ingestion SemVer whenever your changes affect ingestion, parsing, or any stored workout/physiometrics schema.

---

## II. Terraform Discipline

### Before Any Apply

Never run `terraform apply` without **first** running `terraform plan` and reviewing every proposed change:

```bash
# 1. ALWAYS run plan first
terraform plan -var-file=environments/prod.tfvars -json > /tmp/plan.json

# 2. Review the plan output for:
#    ✅ SAFE: "create" actions (new resources)
#    ⚠️  CAUTION: "update" actions ([~] — existing resources modified)
#    🚨 DANGER: "delete" actions ([-] — existing resources destroyed)

# 3. Only if plan is satisfactory:
terraform apply -var-file=environments/prod.tfvars
```

### Sentinel Rules

**Never destroy infrastructure without explicit, documented approval:**

- No production data deletion without approval from at least one other team member
- No Key Vault deletion (would lose all application secrets)
- No storage account deletion (would lose all backups and historical data)
- No database deletion (would lose all workout data, physiometrics, etc.)

**If a plan contains unexpected deletions:**

1. Stop immediately — do not apply
2. Investigate why the resource is marked for deletion
3. Check if variables or state changed unexpectedly
4. Get a second opinion before proceeding

---

## III. Multi-Environment Discipline

### Environment Variable Files

Each environment has its own variable file:

- `environments/dev.tfvars` — Development environment (non-production)
- `environments/prod.tfvars` — Production environment (customer-facing, real data)

**Rule: Always specify the correct environment file when planning or applying:**

```bash
# ✅ Correct — explicitly targets environment
terraform plan -var-file=environments/prod.tfvars

# ❌ Wrong — uses default, ambiguous which environment
terraform plan
```

**Rule: Dev and prod must be completely isolated:**

- Different resource groups
- Different storage accounts
- Different Key Vaults
- Different Function App names
- Never mix credentials between dev and prod

---

## IV. State Management

### Remote State is Sacred

- All state is stored in Azure Storage (see `backend.tf`)
- State is the source of truth for infrastructure
- State contains sensitive data (keys, connection strings) — never commit to version control
- `.tfstate` files are **already ignored** by `.gitignore` — do not accidentally commit them

### Before Major Changes: Backup State

```bash
# Create a backup of remote state before applying major changes
az storage blob copy start \
  --account-name "stcoreprod59o7" \
  --source-container "tfstate" \
  --source-blob "health-assistant.tfstate" \
  --destination-container "tfstate-backups" \
  --destination-blob "health-assistant.tfstate.backup.$(date +%Y%m%d_%H%M%S)"
```

### If Something Goes Wrong

If terraform apply partially fails or corrupts state:

```bash
# 1. Do NOT run terraform apply again — this can cause cascading failures
# 2. Investigate the error
# 3. Fix the root cause in the *.tf files
# 4. Run terraform plan again to preview the corrective apply
# 5. Apply only after confirming the plan is safe
```

If state becomes truly corrupted (rare):

```bash
# Last resort: Restore from backup
# Contact team lead before attempting this
az storage blob download \
  --account-name "stcoreprod59o7" \
  --container-name "tfstate-backups" \
  --name "health-assistant.tfstate.backup.TIMESTAMP" \
  --file "./health-assistant.tfstate"

terraform refresh -var-file=environments/prod.tfvars
```

---

## V. Sensitive Data Handling

### Variables in `.tfvars` Files

Some variables contain secrets (connection strings, API keys, etc.):

```hcl
# ❌ Wrong — secrets in plain text
variable "strava_api_key" {
  type        = string
  description = "Strava API key"
}

# ✅ Correct — mark as sensitive
variable "strava_api_key" {
  type        = string
  sensitive   = true
  description = "Strava API key (stored in Key Vault, never logged)"
}
```

### Sample Variable Files

Every `.tfvars` file has a corresponding `.tfvars.sample` showing structure without secrets:

- `environments/prod.tfvars` — **NEVER commit this** (contains real secrets)
- `environments/prod.tfvars.sample` — **DO commit this** (template only, no secrets)

To set up:

```bash
cp environments/prod.tfvars.sample environments/prod.tfvars
# Edit prod.tfvars with real secrets
# prod.tfvars is ignored by .gitignore
```

---

## VI. Module Organization

### Each Module Is Independently Deployable

```
modules/
├── core/              # Shared foundation (RG, DNS, Key Vault, Storage, Log Analytics, OpenAI)
├── baldwin/           # Static website + Baldwin Function App
├── the_rob_vault/     # SQL DB + Rob Vault backend + OpenAI deployment
└── health-assistant/  # Health data ingestion (storage + app + integrations)
```

**Rule: Each module must declare its own dependencies explicitly:**

```hcl
# Example: modules/health-assistant/main.tf
module "health_assistant" {
  source = "./modules/health-assistant"
  
  # Explicit dependencies on core
  resource_group_name           = module.core.resource_group_name
  location                      = module.core.location
  key_vault_id                  = module.core.key_vault_id
  application_insights_id       = module.core.application_insights_id
  app_service_plan_id           = module.core.app_service_plan_id
  
  # Project-specific variables
  environment = "prod"
}
```

**Rule: Avoid cross-module dependencies except through Core:**

- `core` is the hub; other modules are leaves
- If Baldwin needs something from Health Assistant: this is wrong design, fix it
- All inter-module data flows through Core

---

## VII. Coordination with health-assistant Repository

This infrastructure enables the **health-assistant** application.

### When health-assistant Needs Infrastructure Changes

**If health-assistant team requests a new secret or configuration:**

1. Add the secret to `modules/health-assistant/main.tf` (Key Vault secret)
2. `terraform plan -var-file=environments/prod.tfvars` (preview the change)
3. `terraform apply -var-file=environments/prod.tfvars` (apply to Azure)
4. health-assistant code can now read the secret via Managed Identity

**If health-assistant team requests infrastructure scaling:**

- Update `modules/health-assistant/variables.tf` (e.g., `app_service_plan_sku`)
- Update `environments/prod.tfvars` with new values
- `terraform plan` → `terraform apply`
- health-assistant redeploys onto scaled infrastructure

**If health-assistant wants a new storage table:**

- health-assistant code is responsible for the schema (Python code owns table structure)
- azure-infra only need to provision the storage account (already done in `modules/health-assistant`)
- health-assistant likely does NOT need infrastructure changes
- If it does, update `modules/health-assistant/main.tf` (storage account properties)

---

## VIII. Deployment Safety Checklist

Before running `terraform apply` in production:

- [ ] Did you use `-var-file=environments/prod.tfvars`? (not dev or blank)
- [ ] Did you run `terraform plan` first and review all changes?
- [ ] Are there any `delete` actions that would destroy production data?
- [ ] Did you verify all `sensitive = true` variables are properly marked?
- [ ] Have you backed up state if this is a major change?
- [ ] Did you test this change in dev environment first?
- [ ] Do you have a rollback plan if something goes wrong?
- [ ] Have you notified the team if this affects shared infrastructure (Core module)?

If you cannot check all boxes, do not apply.

---

## IX. Common Patterns

### Adding a New OAuth Integration (e.g., Strava)

```hcl
# 1. Update modules/health-assistant/main.tf
resource "azurerm_key_vault_secret" "strava_client_id" {
  name         = "strava-client-id"
  value        = var.strava_client_id
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_key_vault_access_policy.app]
}

resource "azurerm_key_vault_secret" "strava_client_secret" {
  name         = "strava-client-secret"
  value        = var.strava_client_secret
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_key_vault_access_policy.app]
}

# 2. Update modules/health-assistant/variables.tf
variable "strava_client_id" {
  type        = string
  sensitive   = true
  description = "Strava OAuth client ID"
}

variable "strava_client_secret" {
  type        = string
  sensitive   = true
  description = "Strava OAuth client secret"
}

# 3. Update environments/prod.tfvars
strava_client_id     = "<real-strava-id>"
strava_client_secret = "<real-strava-secret>"

# 4. terraform plan → terraform apply
# Secrets are now in Key Vault; health-assistant can read them
```

### Scaling the Function App

```hcl
# 1. Update environments/prod.tfvars
app_service_plan_sku = "B2"  # Changed from B1 to B2 (more compute)

# 2. terraform plan -var-file=environments/prod.tfvars
# Review: Azure App Service Plan will be updated to B2 SKU

# 3. terraform apply -var-file=environments/prod.tfvars
# App Service Plan scaled; Function App redeploys automatically
```

### Changing Storage Lifecycle Policy

```hcl
# Update modules/health-assistant/main.tf
resource "azurerm_storage_management_policy" "health_assistant" {
  storage_account_id = azurerm_storage_account.health_assistant.id

  rule {
    name    = "archive_old_backups"
    enabled = true
    
    # Changed: 30 days → 60 days
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than       = 60
        tier_to_archive_after_days_since_modification_greater_than   = 90
        delete_after_days_since_modification_greater_than            = 365
      }
    }
    # ... rest of policy
  }
}
```

---

## X. Anti-Patterns (Never Do These)

❌ **Running `terraform apply` without `terraform plan` first**
```bash
# Wrong — flying blind
terraform apply
```

❌ **Forgetting to specify environment file**
```bash
# Wrong — could apply to wrong environment
terraform plan
terraform apply
```

❌ **Storing secrets in version control**
```bash
# Wrong — exposes API keys in git history
echo "api_key = 'super-secret'" >> environments/prod.tfvars
git add environments/prod.tfvars
```

❌ **Modifying state files directly**
```bash
# Wrong — corrupts Terraform's source of truth
vi terraform.tfstate  # DO NOT DO THIS
```

❌ **Cross-module dependencies (except via Core)**
```hcl
# Wrong — creates tight coupling
module "baldwin" {
  source = "./modules/baldwin"
  health_assistant_url = module.health_assistant.function_app_url
}
```

---

## Summary

| Principle | Rule |
|-----------|------|
| **Always plan before applying** | `terraform plan` → review → `terraform apply` |
| **Specify environment file** | `-var-file=environments/prod.tfvars` (never blank) |
| **Sensitive data marked** | `sensitive = true` on all secrets |
| **State is sacred** | Never edit `.tfstate` files directly |
| **Modules are independent** | Dependencies flow through Core only |
| **Coordination with health-assistant** | They request infrastructure; we provision it safely |

---

**Last updated**: March 2026
**Maintainers**: @rbarrimond