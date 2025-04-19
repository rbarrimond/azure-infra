# azure-infra

```plaintext
azure-infra/
├── main.tf                  # Core + use case orchestration
├── backend.tf               # Optional: Remote state config (e.g. Azure Storage)
├── locals.tf                # Naming suffixes, region, tags
├── tags.tf                  # Standard tag definitions
├── variables.tf             # Global config vars
├── outputs.tf               # Shared outputs (DNS, vault URI, etc.)

├── modules/
│   ├── core/                # DNS zone, KV, Function App Plan, App Insights
│   ├── feeds/               # Project-specific queue/table/blob/function
│   ├── poster/
│   ├── analytics/
│   └── shared_ai/           # Optional: reusable AI pipeline module

├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
```
