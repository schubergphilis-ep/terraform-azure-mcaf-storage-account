mock_provider "azurerm" {}

mock_provider "time" {}

run "plans_successfully_when_key_is_not_yet_known" {
  command = plan

  module {
    source = "./tests/fixtures/with_cmk"
  }

  assert {
    condition     = output.storage_account_name == "teststorageaccount"
    error_message = "Should plan successfully even though the key ids are unknown until apply."
  }
}
