# Azure Container Registry (ACR) Configuration template:
# - ACR with tiered options (Basic, Standard, Premium)
# - Security features (encryption, private endpoints)
# - Image vulnerability scanning
# - Geo-replication (Premium tier)
# - Lifecycle policies
# Author: @mrexojo
# Last update: May 2025
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry

# Required provider configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Main ACR resource
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Optional identity configuration for managed identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type = var.identity_type
    }
  }

  # The following options are only available for Premium SKU
  public_network_access_enabled = !var.enable_network_rules || var.network_default_action == "Allow"
  network_rule_bypass_option    = "AzureServices"

  # These options handle features per-SKU availability
  export_policy_enabled  = true
  anonymous_pull_enabled = false
  data_endpoint_enabled  = var.sku == "Premium" ? true : false

  tags = merge(
    var.tags,
    {
      Name        = var.acr_name
      Maintainer  = var.maintainer
      Project     = var.project
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  )
}

# Private Endpoint for network isolation
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  count               = var.create_private_endpoint ? 1 : 0
  name                = "${var.acr_name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.acr_name}-private-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  tags = var.tags
}

# Vulnerability scanning with Microsoft Defender
resource "azurerm_security_center_subscription_pricing" "acr_defender" {
  count         = var.enable_vulnerability_scanning ? 1 : 0
  tier          = "Standard"
  resource_type = "ContainerRegistry"
}

# Webhook for CI/CD integration
resource "azurerm_container_registry_webhook" "webhooks" {
  for_each            = var.webhooks
  name                = each.key
  resource_group_name = var.resource_group_name
  registry_name       = azurerm_container_registry.acr.name
  location            = var.location

  service_uri = each.value.service_uri
  status      = each.value.status
  scope       = each.value.scope
  actions     = each.value.actions

  custom_headers = each.value.custom_headers
}