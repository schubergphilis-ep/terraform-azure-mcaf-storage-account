data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "this" {
  #checkov:skip=CKV_AZURE_190:"Ensure that Storage blobs restrict public access" - allow_nested_items_to_be_public defaults to false and is configurable via network_configuration
  #checkov:skip=CKV2_AZURE_47:"Ensure storage account is configured without blob anonymous access" - blob anonymous access disabled by default (allow_nested_items_to_be_public=false)
  #checkov:skip=CKV_AZURE_59:"Ensure that Storage accounts disallow public access" - public_network_access_enabled defaults to false and is configurable via network_configuration
  #checkov:skip=CKV_AZURE_244:"Avoid the use of local users for Azure Storage unless necessary" - local users are an opt-in SFTP feature, disabled by default (sftp_enabled=false)
  #checkov:skip=CKV_AZURE_206:"Ensure that Storage Accounts use replication" - replication type is configurable; module defaults to ZRS by design
  #checkov:skip=CKV_AZURE_33:"Ensure Storage logging is enabled for Queue service for read, write and delete requests" - queue service logging is out of scope for this module
  #checkov:skip=CKV2_AZURE_33:"Ensure storage account is configured with private endpoint" - private endpoints are provisioned outside this module
  resource_group_name               = var.resource_group_name
  location                          = var.location
  name                              = var.name
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  access_tier                       = var.access_tier
  shared_access_key_enabled         = var.shared_access_key_enabled
  public_network_access_enabled     = var.network_configuration.public_network_access_enabled
  https_traffic_only_enabled        = var.network_configuration.https_traffic_only_enabled
  min_tls_version                   = var.min_tls_version
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  allowed_copy_scope                = var.allowed_copy_scope == "Unrestricted" ? null : var.allowed_copy_scope
  sftp_enabled                      = var.sftp_enabled
  is_hns_enabled                    = var.is_hns_enabled
  provisioned_billing_model_version = var.provisioned_billing_model_version
  allow_nested_items_to_be_public   = var.network_configuration.allow_nested_items_to_be_public
  queue_encryption_key_type         = (var.enable_cmk_encryption || var.cmk_key_vault_id != null) ? "Account" : "Service"
  table_encryption_key_type         = (var.enable_cmk_encryption || var.cmk_key_vault_id != null) ? "Account" : "Service"

  dynamic "blob_properties" {
    for_each = var.account_kind != "FileStorage" ? [1] : []

    content {
      delete_retention_policy {
        days = var.storage_management_policy.blob_delete_retention_days
      }
      container_delete_retention_policy {
        days = var.storage_management_policy.container_delete_retention_days
      }
      versioning_enabled  = var.versioning_enabled
      change_feed_enabled = var.change_feed_enabled
    }
  }

  dynamic "identity" {
    for_each = coalesce(local.identity_system_assigned_user_assigned, local.identity_system_assigned, local.identity_user_assigned, {})

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "immutability_policy" {
    for_each = var.immutability_policy != null ? { this = var.immutability_policy } : {}

    content {
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes
      state                         = immutability_policy.value.state
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days
    }
  }

  dynamic "share_properties" {
    for_each = var.share_properties == null ? [] : [var.share_properties]

    content {
      dynamic "retention_policy" {
        for_each = share_properties.value.retention_policy == null ? [] : [share_properties.value.retention_policy]

        content {
          days = retention_policy.value.days
        }
      }

      dynamic "smb" {
        for_each = share_properties.value.smb == null ? [] : [share_properties.value.smb]

        content {
          authentication_types            = smb.value.authentication_types
          channel_encryption_type         = smb.value.channel_encryption_type
          kerberos_ticket_encryption_type = smb.value.kerberos_ticket_encryption_type
          multichannel_enabled            = smb.value.multichannel_enabled
          versions                        = smb.value.versions
        }
      }
    }
  }

  dynamic "azure_files_authentication" {

    for_each = var.azure_files_authentication != null ? { this = var.azure_files_authentication } : {}
    content {
      directory_type = azure_files_authentication.value.directory_type
      dynamic "active_directory" {
        for_each = azure_files_authentication.value.active_directory != null ? { this = azure_files_authentication.value.active_directory } : {}
        content {
          domain_name         = active_directory.value.domain_name
          domain_guid         = active_directory.value.domain_guid
          domain_sid          = active_directory.value.domain_sid
          storage_sid         = active_directory.value.storage_sid
          forest_name         = active_directory.value.forest_name
          netbios_domain_name = active_directory.value.netbios_domain_name
        }
      }
      default_share_level_permission = azure_files_authentication.value.default_share_level_permission
    }
  }

  tags = merge(
    try(var.tags),
    tomap({
      "Resource Type" = "Storage Account"
    })
  )

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]

    precondition {
      condition     = var.provisioned_billing_model_version == null || var.account_kind == "FileStorage"
      error_message = "provisioned_billing_model_version can only be set when account_kind is 'FileStorage'."
    }

    precondition {
      condition     = var.provisioned_billing_model_version == null || var.account_tier == "Premium"
      error_message = "provisioned_billing_model_version can only be set when account_tier is 'Premium'."
    }
  }
}

resource "azurerm_storage_account_network_rules" "this" {
  #checkov:skip=CKV_AZURE_35:"Ensure default network access rule for Storage Accounts is set to deny" - default_action defaults to Deny and is configurable via network_configuration
  #checkov:skip=CKV_AZURE_36:"Ensure 'Trusted Microsoft Services' is enabled for Storage Account access" - bypass defaults to ["AzureServices"] and is configurable via network_configuration
  storage_account_id = azurerm_storage_account.this.id

  default_action             = var.network_configuration.default_action
  ip_rules                   = var.network_configuration.ip_rules
  virtual_network_subnet_ids = var.network_configuration.virtual_network_subnet_ids
  bypass                     = var.network_configuration.bypass
}

resource "azurerm_storage_management_policy" "this" {
  count              = length(compact([var.storage_management_policy.move_to_cool_after_days, var.storage_management_policy.move_to_cold_after_days, var.storage_management_policy.move_to_archive_after_days, var.storage_management_policy.delete_after_days])) > 0 ? 1 : 0
  storage_account_id = azurerm_storage_account.this.id

  rule {
    name    = "Storage Account Module builtin management policy"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = var.storage_management_policy.move_to_cool_after_days
        tier_to_cold_after_days_since_creation_greater_than     = var.storage_management_policy.move_to_cold_after_days
        tier_to_archive_after_days_since_creation_greater_than  = var.storage_management_policy.move_to_archive_after_days
        delete_after_days_since_modification_greater_than       = var.storage_management_policy.delete_after_days
      }
    }
  }
}

resource "azurerm_storage_container" "this" {
  #checkov:skip=CKV_AZURE_34:"Ensure that 'Public access level' is set to Private for blob containers" - container_access_type defaults to "private" and is configurable per container
  #checkov:skip=CKV2_AZURE_21:"Ensure Storage logging is enabled for Blob service for read requests" - blob read logging is handled via diagnostic settings outside this module
  for_each = var.storage_containers

  name                  = each.key
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = each.value.access_type
}

resource "azurerm_storage_share" "this" {
  for_each = var.storage_file_shares

  name               = each.key
  storage_account_id = azurerm_storage_account.this.id
  # access_tier must be null for NFS shares AND for any share on a FileStorage
  # account; Azure rejects any non-null value in either case with 400
  # AccessTierNotSupported. The variable still defaults to "Hot" so consumers
  # don't need to know which combinations require null — the module nulls it
  # transparently where Azure mandates it.
  access_tier      = (each.value.enabled_protocol == "NFS" || var.account_kind == "FileStorage") ? null : each.value.access_tier
  enabled_protocol = each.value.enabled_protocol
  quota            = each.value.quota

  lifecycle {
    precondition {
      condition     = each.value.provisioned_iops == null && each.value.provisioned_throughput_in_mibps == null || var.provisioned_billing_model_version == "V2"
      error_message = "provisioned_iops and provisioned_throughput_in_mibps can only be set when provisioned_billing_model_version is 'V2'."
    }
  }
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "extra" {
  for_each = { for idx, val in var.contributors : idx => val }

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

resource "azurerm_storage_account_customer_managed_key" "this" {
  count = var.cmk_key_vault_id != null ? 1 : 0

  storage_account_id        = azurerm_storage_account.this.id
  user_assigned_identity_id = local.identity_user_assigned != null ? var.user_assigned_identities[0] : null
  key_vault_id              = var.cmk_key_vault_id
  key_name                  = var.cmk_key_name

  depends_on = [
    azurerm_role_assignment.cmk
  ]
}

resource "azurerm_role_assignment" "cmk" {
  count = (var.cmk_key_vault_id != null && (local.identity_system_assigned != null || local.identity_system_assigned_user_assigned != null)) ? 1 : 0

  scope                = var.cmk_key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.this.identity[0].principal_id
}

resource "azurerm_data_protection_backup_instance_blob_storage" "this" {
  count                           = var.blob_storage_backup != null ? 1 : 0
  name                            = var.blob_storage_backup.name
  location                        = var.location
  vault_id                        = var.blob_storage_backup.backup_vault_id
  storage_account_id              = azurerm_storage_account.this.id
  backup_policy_id                = var.blob_storage_backup.backup_policy_id
  storage_account_container_names = var.blob_storage_backup.container_names
}

resource "azurerm_storage_account_local_user" "self" {
  count              = var.sftp_enabled != false && var.sftp_enabled == true ? length(var.sftp_local_user_config) : 0
  name               = var.sftp_local_user_config[count.index].name
  storage_account_id = azurerm_storage_account.this.id
  ssh_key_enabled    = true
  home_directory     = var.sftp_local_user_config[count.index].home_directory

  dynamic "ssh_authorized_key" {
    for_each = var.sftp_local_user_config[count.index].ssh_authorized_keys
    content {
      description = ssh_authorized_key.value.description
      key         = ssh_authorized_key.value.key
    }
  }

  dynamic "permission_scope" {
    for_each = var.sftp_local_user_config[count.index].permission_scopes
    content {
      service       = permission_scope.value.service
      resource_name = permission_scope.value.resource_name
      permissions {
        read   = permission_scope.value.permissions.read
        create = permission_scope.value.permissions.create
        delete = permission_scope.value.permissions.delete
        list   = permission_scope.value.permissions.list
        write  = permission_scope.value.permissions.write
      }
    }
  }
}
