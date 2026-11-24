mock_provider "azurerm" {}

variables {
  name                     = "sttestcmkexisting"
  resource_group_name      = "rg-test"
  location                 = "westeurope"
  user_assigned_identities = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"]
}

run "create_without_cmk" {
  command = apply
}

run "attach_on_create_rejected_for_existing_account" {
  command = plan

  variables {
    cmk_key = {
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
      attach_on_create        = true
    }
  }

  expect_failures = [azurerm_storage_account.this]
}
