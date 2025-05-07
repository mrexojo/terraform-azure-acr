variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the ACR will be created"
  type        = string
}

variable "location" {
  description = "Azure region where the ACR will be deployed"
  type        = string
}

variable "sku" {
  description = "The SKU of the container registry (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be either Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for the ACR. Not recommended for production environments"
  type        = bool
  default     = false
}

variable "maintainer" {
  description = "Name of the maintainer of the ACR"
  type        = string
}

variable "project" {
  description = "Project name or code"
  type        = string
}

variable "author" {
  description = "Author of the module"
  type        = string
  default     = "@mrexojo"
}

variable "environment" {
  description = "Environment (dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "A map of tags to apply to the resources"
  type        = map(string)
  default     = {}
}

# Identity configuration
variable "identity_type" {
  description = "The type of identity to create (SystemAssigned, UserAssigned, SystemAssigned,UserAssigned, null)"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned"], var.identity_type)
    error_message = "Identity type must be either SystemAssigned, UserAssigned, SystemAssigned,UserAssigned, or null."
  }
}

# Encryption configuration
variable "encryption_enabled" {
  description = "Enable customer-managed key encryption (Premium SKU only)"
  type        = bool
  default     = false
}

variable "key_vault_key_id" {
  description = "Key Vault key ID to use for encryption (required when encryption_enabled is true)"
  type        = string
  default     = null
}

variable "identity_client_id" {
  description = "Client ID of the user-assigned identity for encryption (required for UserAssigned identity type)"
  type        = string
  default     = null
}

# Retention policy
variable "enable_retention_policy" {
  description = "Enable image retention policy"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Number of days to retain images when untagged"
  type        = number
  default     = 7
}

# Network rules
variable "enable_network_rules" {
  description = "Enable network rules for ACR access"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default action for network rules (Allow or Deny)"
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "Network default action must be either Allow or Deny."
  }
}

variable "allowed_ips" {
  description = "List of IP addresses or CIDR blocks allowed to access the ACR"
  type        = list(string)
  default     = []
}

variable "allowed_subnets" {
  description = "List of subnet IDs allowed to access the ACR"
  type        = list(string)
  default     = []
}

# Content trust
variable "enable_content_trust" {
  description = "Enable content trust for image signing (Premium SKU only)"
  type        = bool
  default     = false
}

# Geo-replication
variable "enable_geo_replication" {
  description = "Enable geo-replication for ACR (Premium SKU only)"
  type        = bool
  default     = false
}

variable "geo_replica_locations" {
  description = "Map of locations to replicate to and their configuration"
  type = map(object({
    zone_redundancy_enabled   = bool
    regional_endpoint_enabled = bool
  }))
  default = {}
}

# Private endpoint
variable "create_private_endpoint" {
  description = "Create a private endpoint for the ACR"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint (required when create_private_endpoint is true)"
  type        = string
  default     = null
}

# Vulnerability scanning
variable "enable_vulnerability_scanning" {
  description = "Enable Microsoft Defender vulnerability scanning for ACR"
  type        = bool
  default     = false
}

# Webhooks
variable "webhooks" {
  description = "Map of webhooks to create for the ACR"
  type = map(object({
    service_uri    = string
    status         = string
    scope          = string
    actions        = list(string)
    custom_headers = map(string)
  }))
  default = {}
}