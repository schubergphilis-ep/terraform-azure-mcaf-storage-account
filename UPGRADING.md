# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.


## Upgrading to v3.0.1

The `cmk_key` object now takes the two versionless attributes of the Key Vault key, so the module can attach the CMK (data-plane URL) and
correctly scope the storage identity's role assignment (ARM resource id).
The v3.0.0 `key_vault_key_id` shape could not complete an apply — the role-assignment scope wasinvalid — so this ships as a patch.

#### Before

```hcl
cmk_key = {
  key_vault_key_id = azurerm_key_vault_key.example.versionless_id
}
```

#### After

```hcl
cmk_key = {
  resource_versionless_id = azurerm_key_vault_key.example.resource_versionless_id
  versionless_id          = azurerm_key_vault_key.example.versionless_id
}
```

## Upgrading to v3.0.0

#### Before

```hcl
module "storage_account" {
  source = "schubergphilis-ep/mcaf-storage-account/azure"

  # ...
  cmk_key = {
    key_vault_id = module.key_vault.key_vault_id
    key_name     = module.key_vault.cmkrsa_key_name
  }
}
```

#### After

```hcl
module "storage_account" {
  source = "schubergphilis-ep/mcaf-storage-account/azure"

  # ...
  cmk_key = {
    key_vault_key_id = module.key_vault.key_vault_id
  }
}
```

## Upgrading to v2.0.0

### `cmk_key_vault_id` / `cmk_key_name` variables replaced by `cmk_key`

The `cmk_key_vault_id` and `cmk_key_name` variables have been replaced by a single `cmk_key` object variable, so that attaching a Customer Managed Key no longer depends on `cmk_key_vault_id` being known at plan time (for example, when the referenced Key Vault is created in the same apply as this storage account).

#### Before

```hcl
module "storage_account" {
  source = "schubergphilis-ep/mcaf-storage-account/azure"

  # ...
  cmk_key_vault_id = module.key_vault.key_vault_id
  cmk_key_name     = module.key_vault.cmkrsa_key_name
}
```

#### After

```hcl
module "storage_account" {
  source = "schubergphilis-ep/mcaf-storage-account/azure"

  # ...
  cmk_key = {
    key_vault_id = module.key_vault.key_vault_id
    key_name     = module.key_vault.cmkrsa_key_name
  }
}
```

#### Migration steps

1. Combine your existing `cmk_key_vault_id` and `cmk_key_name` values into a single `cmk_key` object with `key_vault_id` and `key_name` attributes.
2. Remove the old `cmk_key_vault_id` and `cmk_key_name` arguments.
3. If you don't attach a Customer Managed Key, no change is needed — `cmk_key` defaults to `null`, same as before.

`enable_cmk_encryption` (controlling `queue_encryption_key_type`/`table_encryption_key_type`) is unaffected by this change.
