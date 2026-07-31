mock_provider "azurerm" {}

run "plans_successfully_when_key_vault_id_is_not_yet_known" {
  command = plan

  module {
    source = "./tests/fixtures/with_cmk"
  }

  assert {
    condition     = output.storage_account_name == "teststorageaccount"
    error_message = "Should plan successfully even though cmk_key.key_vault_id is unknown until apply."
  }
}
