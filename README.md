
# azure-infra

This repository contains my personal Infrastructure as Code (IaC) code base for managing and deploying resources for my personal projects. It includes Terraform modules, environment configurations, and supporting files used to provision and maintain cloud infrastructure.



```plaintext
azure-infra
├── azure-pipelines.yml
├── backend.tf
├── environments
│   ├── dev.tfvars
│   ├── dev.tfvars.sample
│   ├── prod.tfvars
│   └── prod.tfvars.sample
├── errored.tfstate
├── main.tf
├── modules
│   ├── baldwin
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── core
│   │   ├── autoscale.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── the_rob_vault
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── README.md
├── static
│   ├── 404.html
│   └── index.html
├── terraform.tfvars
└── variables.tf
```
