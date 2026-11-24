mock_provider "azurerm" {}

run "plans_successfully_when_key_and_identity_are_not_yet_known" {
  command = plan

  module {
    source = "./tests/fixtures/with_cmk"
  }

  assert {
    condition     = output.storage_account_name == "teststorageaccount"
    error_message = "Should plan successfully even though the key and identity ids are unknown until apply."
  }
}
