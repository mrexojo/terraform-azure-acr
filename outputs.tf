output "acr_id" {
  description = "The ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "The Admin Username for the Container Registry (if admin_enabled is true)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
  sensitive   = true
}

output "acr_admin_password" {
  description = "The Admin Password for the Container Registry (if admin_enabled is true)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}

output "acr_identity_principal_id" {
  description = "The Principal ID for the system-assigned identity (if enabled)"
  value       = var.identity_type != null ? azurerm_container_registry.acr.identity.0.principal_id : null
}

output "acr_identity_tenant_id" {
  description = "The Tenant ID for the system-assigned identity (if enabled)"
  value       = var.identity_type != null ? azurerm_container_registry.acr.identity.0.tenant_id : null
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)"
  value       = var.create_private_endpoint ? azurerm_private_endpoint.acr_private_endpoint[0].id : null
}

output "private_endpoint_ip_addresses" {
  description = "The IP addresses of the private endpoint (if created)"
  value       = var.create_private_endpoint ? azurerm_private_endpoint.acr_private_endpoint[0].private_service_connection.0.private_ip_address : null
}

output "webhooks" {
  description = "The webhooks created for the Azure Container Registry"
  value       = length(var.webhooks) > 0 ? azurerm_container_registry_webhook.webhooks : null
  sensitive   = true
}

output "replica_endpoints" {
  description = "The login servers of the geo-replicated registries (if enabled)"
  value = var.sku == "Premium" && var.enable_geo_replication ? {
    for location in keys(var.geo_replica_locations) :
    location => "${azurerm_container_registry.acr.name}.${location}.data.azurecr.io"
  } : null
}