# Mirrors the module's customer-managed-key plan test, run against this folder's
# pinned azurerm major. Keep identical to provider-v5/with_cmk.tftest.hcl.
#
# The fixture creates a key vault + key and feeds the module a cmk_key whose
# key_vault_id is unknown until apply, exercising the plan path. The fixture's
# key vault sets rbac_authorization_enabled (required by azurerm 5.0, accepted by
# 4.x), so this test passes under both majors.
mock_provider "azurerm" {}

run "plans_successfully_when_key_vault_id_is_not_yet_known" {
  command = plan

  module {
    source = "../fixtures/with_cmk"
  }

  assert {
    condition     = output.storage_account_name == "teststorageaccount"
    error_message = "Should plan successfully even though cmk_key.key_vault_id is unknown until apply."
  }
}
