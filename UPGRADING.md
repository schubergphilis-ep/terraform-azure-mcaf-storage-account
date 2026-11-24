# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v4.0.0

Support for the system-assigned identity was removed. A system-assigned identity only exists after the storage account is created, so it can't be granted access to a key before creation. That made it impossible to set a CMK in the create request, which Azure policies requiring CMK encryption need. The storage account now only uses user-assigned identities, and the CMK is set on the storage account itself.

### Changes

- The `system_assigned_identity_enabled` variable and the `system_assigned_identity_id` output were removed. The storage account no longer has a system-assigned identity.
- `cmk_key` now takes the key id and the user-assigned identity that accesses it. That identity is attached to the storage account automatically.
- The module no longer grants the identity access to the key. Assign `Key Vault Crypto Service Encryption User` on the key yourself before applying.
- `azurerm_storage_account_customer_managed_key.this` and `azurerm_role_assignment.cmk` were removed. `removed` blocks drop them from state without destroying them, so the account keeps its CMK and key access during the upgrade.

#### Before

```hcl
module "storage_account" {
  source = "schubergphilis-ep/mcaf-storage-account/azure"

  # ...
  cmk_key = {
    resource_versionless_id = azurerm_key_vault_key.example.resource_versionless_id
    versionless_id          = azurerm_key_vault_key.example.versionless_id
  }
}
```

#### After

```hcl
resource "azurerm_user_assigned_identity" "storage" {
  # ...
}

resource "azurerm_role_assignment" "storage_cmk" {
  scope                = azurerm_key_vault_key.example.resource_versionless_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

module "storage_account" {
  source = "schubergphilis-ep/mcaf-storage-account/azure"

  # ...
  cmk_key = {
    key_vault_key_id          = azurerm_key_vault_key.example.versionless_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  depends_on = [azurerm_role_assignment.storage_cmk]
}
```

See `examples/cmk` for a complete example.

### Migration steps

1. If anything outside this module uses the `system_assigned_identity_id` output (for example role assignments for the storage account), move it to a user-assigned identity first. The system-assigned identity is deleted when you apply v4.0.0, which happens by default even without a CMK, because `system_assigned_identity_enabled` defaulted to `true`.
2. If you use a CMK, create a user-assigned identity and grant it `Key Vault Crypto Service Encryption User` on the key. Apply this before upgrading the module, so the role assignment has taken effect.
3. Update `cmk_key` to the new shape and remove `system_assigned_identity_enabled`.
4. Run `terraform plan`. Expect the storage account to be updated in place: the identity changes to `UserAssigned` and `customer_managed_key` is set. The two removed resources are dropped from state, not destroyed. If the plan wants to replace the storage account, stop.
5. After the apply, you can delete the old role assignment for the system-assigned identity on the key. It was kept on purpose and now points to an identity that no longer exists.

## Upgrading to v3.0.1

The `cmk_key` object now takes the two versionless attributes of the Key Vault key, so the module can attach the CMK (data-plane URL) and
correctly scope the storage identity's role assignment (ARM resource id). The role assignment is now scoped to the **specific CMK key** (`Key Vault Crypto ServiceEncryption User` on the key — least privilege) rather than the parent Key Vault; if you relied on the storage identity having vault-wide crypto access, note this narrower scope.The v3.0.0 `key_vault_key_id` shape could not complete an apply, so this ships as a
patch.

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
