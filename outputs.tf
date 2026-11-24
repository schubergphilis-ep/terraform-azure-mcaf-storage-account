output "id" {
  value       = azurerm_storage_account.this.id
  description = "Resource Id of the storage account"
}

output "name" {
  value       = azurerm_storage_account.this.name
  description = "Name of the storage account"
}

output "endpoints" {
  value = {
    primary_blob_endpoint  = azurerm_storage_account.this.primary_blob_endpoint
    primary_blob_host      = azurerm_storage_account.this.primary_blob_host
    primary_dfs_endpoint   = azurerm_storage_account.this.primary_dfs_endpoint
    primary_dfs_host       = azurerm_storage_account.this.primary_dfs_host
    primary_file_endpoint  = azurerm_storage_account.this.primary_file_endpoint
    primary_file_host      = azurerm_storage_account.this.primary_file_host
    primary_queue_endpoint = azurerm_storage_account.this.primary_queue_endpoint
    primary_queue_host     = azurerm_storage_account.this.primary_queue_host
    primary_table_endpoint = azurerm_storage_account.this.primary_table_endpoint
    primary_table_host     = azurerm_storage_account.this.primary_table_host
    primary_web_endpoint   = azurerm_storage_account.this.primary_web_endpoint
  }
  description = "Endpoint information of the storage account"
}

output "access_keys" {
  value = {
    primary   = azurerm_storage_account.this.primary_access_key
    secondary = azurerm_storage_account.this.secondary_access_key
  }
  sensitive = true
}

output "storage_share_ids" {
  value       = { for key, share in azurerm_storage_share.this : key => share.id }
  description = "Resource Manager IDs for each storage file share"
}

output "identity" {
  value = {
    id           = azurerm_user_assigned_identity.this.id
    principal_id = azurerm_user_assigned_identity.this.principal_id
    client_id    = azurerm_user_assigned_identity.this.client_id
  }
  description = "The user-assigned identity of the storage account. Use principal_id to grant the storage account access to other resources."
}
