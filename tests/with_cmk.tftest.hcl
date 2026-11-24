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

run "plans_successfully_with_attach_on_create_when_key_is_not_yet_known" {
  command = plan

  module {
    source = "./tests/fixtures/with_cmk"
  }

  assert {
    condition     = output.storage_account_cmk_on_create_name == "teststorageaccountcmk"
    error_message = "Should plan successfully with attach_on_create even though the key and identity ids are unknown until apply."
  }
}
