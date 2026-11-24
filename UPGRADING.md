# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v4.0.0

The storage account now gets its own user-assigned identity, created by the module and 1:1 with the storage account. It replaces the system-assigned identity and the `user_assigned_identities` input. A system-assigned identity only exists after the storage account is created, so it can't be granted access to a key before creation. That made it impossible to set a CMK in the create request, which Azure policies requiring CMK encryption need.

When `cmk_key` is set, the module grants this identity `Key Vault Crypto Service Encryption User` on the key, waits for the role assignment to take effect, and sets the CMK on the storage account itself.

### Changes

- Removed the `system_assigned_identity_enabled` and `user_assigned_identities` variables and the `system_assigned_identity_id` output.
- Added the `identity` output (`id`, `principal_id`, `client_id`). The identity has the same name as the storage account.
- The `cmk_key` input is unchanged.
- `azurerm_storage_account_customer_managed_key.this` was removed. A `removed` block drops it from state without destroying it, so the account keeps its CMK during the upgrade.
- `azurerm_role_assignment.cmk` is now for the module's identity. The old assignment for the system-assigned identity is destroyed and a new one created.
- The module now also requires the `hashicorp/time` provider.

The module's identity is created in `resource_group_name`, so the identity running Terraform needs permission to create managed identities there. To grant the CMK role, it also needs permission to create role assignments on the key, for example `Role Based Access Control Administrator` or `Owner`.

### Migration steps

1. Anything outside this module that used the `system_assigned_identity_id` output (for example role assignments that let the storage account access other resources) has to move to `module.<name>.identity.principal_id`. The system-assigned identity is deleted on upgrade, even without a CMK, because `system_assigned_identity_enabled` defaulted to `true`.
2. Remove `system_assigned_identity_enabled` and `user_assigned_identities` from the module call. If you passed in a user-assigned identity, grant the module's identity whatever that identity had access to.
3. Run `terraform plan`. Expect:
   - a new `azurerm_user_assigned_identity.this` and, with a CMK, a new `time_sleep.cmk_role_propagation`
   - `azurerm_role_assignment.cmk` replaced (new identity)
   - the storage account updated in place: identity changes to `UserAssigned`, and `customer_managed_key` is set
   - `azurerm_storage_account_customer_managed_key.this` removed from state, not destroyed

   If the plan wants to replace the storage account, stop.

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
