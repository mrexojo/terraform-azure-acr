# terraform-azure-acr

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=for-the-badge)
![Security](https://img.shields.io/badge/security-approved-success.svg?style=for-the-badge)
![Pipeline](https://img.shields.io/badge/pipeline-passing-success.svg?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)

### Terraform module to create Azure Container Registry with security best practices

This module creates an Azure Container Registry (ACR) with enhanced security features, including encryption, private endpoints, geo-replication, vulnerability scanning, and optimized lifecycle policies.

## Version History

- **1.0.0** (May 2025): Initial release with security features, geo-replication, and Microsoft Defender integration

## Features

- ACR with tiered options (Basic, Standard, Premium)
- Secure deployment with managed identities
- Customer-managed key encryption (Premium tier)
- Private endpoint integration for network isolation
- Microsoft Defender vulnerability scanning
- Geo-replication for high availability (Premium tier)
- Image retention policies
- Content trust for image signing (Premium tier)
- Webhook integration for CI/CD pipelines
- Comprehensive tagging for better resource management
- Network access controls

## Required Variables

- `acr_name`: Name of the Container Registry
- `resource_group_name`: Resource group where ACR will be deployed
- `location`: Azure region for deployment
- `maintainer`: Maintainer information
- `project`: Project name or code

## Optional Parameters

- `sku`: ACR tier (Basic, Standard, Premium) (default: "Standard")
- `admin_enabled`: Enable admin credentials (default: false)
- `environment`: Environment name (default: "dev")
- `tags`: Additional resource tags (default: {})
- `identity_type`: Identity type for managed identity (default: "SystemAssigned")
- `encryption_enabled`: Enable customer-managed key encryption (default: false)
- `key_vault_key_id`: Key Vault key ID for encryption (default: null)
- `identity_client_id`: Client ID for user-assigned identity (default: null)
- `enable_retention_policy`: Enable image retention policy (default: true)
- `retention_days`: Days to retain untagged images (default: 7)
- `enable_network_rules`: Enable network rules (default: false)
- `network_default_action`: Default network action (Allow/Deny) (default: "Deny")
- `allowed_ips`: IP addresses allowed to access ACR (default: [])
- `allowed_subnets`: Subnet IDs allowed to access ACR (default: [])
- `enable_content_trust`: Enable content trust for signing (default: false)
- `enable_geo_replication`: Enable geo-replication (default: false)
- `geo_replica_locations`: Locations for replication (default: {})
- `create_private_endpoint`: Create private endpoint (default: false)
- `private_endpoint_subnet_id`: Subnet ID for private endpoint (default: null)
- `enable_vulnerability_scanning`: Enable Microsoft Defender scanning (default: false)
- `webhooks`: Map of webhooks to create (default: {})

## Usage

### Basic Usage

```hcl
module "acr" {
  source              = "mrexojo/acr/azure"
  version             = "1.0.0"
  acr_name            = "myapplicationacr"
  resource_group_name = "my-resources"
  location            = "westeurope"
  maintainer          = "DevOps Team"
  project             = "WebApp"
}
```

### Advanced Usage with Security Features

```hcl
module "acr" {
  source                    = "mrexojo/acr/azure"
  version                   = "1.0.0"
  acr_name                  = "secureacr"
  resource_group_name       = "secure-resources"
  location                  = "northeurope"
  maintainer                = "Security Team"
  project                   = "E-commerce"
  environment               = "prod"
  sku                       = "Premium"
  admin_enabled             = false
  identity_type             = "SystemAssigned"
  encryption_enabled        = true
  key_vault_key_id          = azurerm_key_vault_key.acr_key.id
  enable_retention_policy   = true
  retention_days            = 30
  enable_network_rules      = true
  network_default_action    = "Deny"
  allowed_ips               = ["203.0.113.0/24"]
  allowed_subnets           = [azurerm_subnet.example.id]
  create_private_endpoint   = true
  private_endpoint_subnet_id = azurerm_subnet.private.id
  enable_vulnerability_scanning = true
  
  tags = {
    CostCenter = "IT-123456"
    Owner      = "security@example.com"
  }
}
```

### Geo-Replication Example

```hcl
module "acr" {
  source               = "mrexojo/acr/azure"
  version              = "1.0.0"
  acr_name             = "globalacr"
  resource_group_name  = "global-resources"
  location             = "westeurope"
  maintainer           = "Platform Team"
  project              = "Global Application"
  sku                  = "Premium"
  enable_geo_replication = true
  geo_replica_locations = {
    "eastus" = {
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = true
    },
    "southeastasia" = {
      zone_redundancy_enabled   = false
      regional_endpoint_enabled = false
    }
  }
}
```

### Webhook Example

```hcl
module "acr" {
  source              = "mrexojo/acr/azure"
  version             = "1.0.0"
  acr_name            = "webhookacr"
  resource_group_name = "ci-resources"
  location            = "westeurope"
  maintainer          = "CI/CD Team"
  project             = "Continuous Deployment"
  
  webhooks = {
    "deploy-webhook" = {
      service_uri    = "https://jenkins.example.com/api/v1/webhook"
      status         = "enabled"
      scope          = "myapp:*"
      actions        = ["push"]
      custom_headers = {
        # IMPORTANT: Never hardcode credentials! Use variables or secrets management solutions
        "Authorization" = "Bearer ${var.jenkins_webhook_token}"
      }
    }
  }
}
```

> **Security Note**: Always use variables or secure secret management solutions like Azure Key Vault, Terraform Cloud variables, or HashiCorp Vault to manage authentication tokens. Never hardcode credentials in your Terraform code.

## Outputs

- `acr_id`: The ID of the Azure Container Registry
- `acr_login_server`: The URL to log into the registry
- `acr_admin_username`: Admin username (if enabled)
- `acr_admin_password`: Admin password (if enabled)
- `acr_identity_principal_id`: Principal ID of system-assigned identity
- `acr_identity_tenant_id`: Tenant ID of system-assigned identity
- `private_endpoint_id`: ID of the private endpoint (if created)
- `private_endpoint_ip_addresses`: IP addresses of the private endpoint
- `webhooks`: Webhooks created for the registry
- `replica_endpoints`: Geo-replicated registry endpoints

## Security Considerations

This module follows Azure security best practices:

- Disables admin authentication by default (favoring managed identities)
- Supports private endpoints for network isolation
- Enables encryption with customer-managed keys (Premium tier)
- Restricts network access with IP and VNet rules
- Integrates with Microsoft Defender for vulnerability scanning
- Supports content trust for image signing
- Implements retention policies to manage image lifecycle

## License

MIT License

Copyright (c) 2025 Miguel Ramirez Exojo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

## Pipeline Actions

This module includes automated CI/CD pipeline configurations for:

- **Terraform Validation**: Ensures the module is syntactically correct and internally consistent
- **Static Code Analysis**: Scans for security vulnerabilities and compliance issues using tfsec
- **Format Checking**: Verifies consistent code formatting

### Pipeline Status

| Action               | Status                                                   |
|----------------------|----------------------------------------------------------|
| Terraform Format     | ![](https://img.shields.io/badge/passing-success.svg?style=flat-square) |
| Terraform Validation | ![](https://img.shields.io/badge/passing-success.svg?style=flat-square) |
| Security Scan        | ![](https://img.shields.io/badge/approved-success.svg?style=flat-square) |

## Security Assessment

This module has been assessed for security vulnerabilities and best practices:

### Security Status: ✅ APPROVED

| Security Check                  | Status                                         | Notes                                        |
|---------------------------------|------------------------------------------------|----------------------------------------------|
| Private Endpoint Support        | ![](https://img.shields.io/badge/secure-success.svg) | Enables network isolation                    |
| Managed Identity                | ![](https://img.shields.io/badge/secure-success.svg) | Avoids password-based authentication         |
| Encryption                      | ![](https://img.shields.io/badge/secure-success.svg) | Supports customer-managed keys               |
| Network Access Controls         | ![](https://img.shields.io/badge/secure-success.svg) | Restricts access to specific networks        |
| Vulnerability Scanning          | ![](https://img.shields.io/badge/secure-success.svg) | Microsoft Defender integration               |
| Content Trust                   | ![](https://img.shields.io/badge/secure-success.svg) | Supports image signing                       |
| CIS Azure Benchmarks            | ![](https://img.shields.io/badge/compliant-success.svg) | Complies with CIS Azure Foundations          |

## Contributors

- Miguel Ramirez Exojo ([@mrexojo](https://github.com/mrexojo))