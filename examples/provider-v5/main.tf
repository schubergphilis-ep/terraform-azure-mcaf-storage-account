# Provider compatibility — azurerm 5.x
#
# This module supports a range of azurerm majors (terraform.tf pins ">= 4, < 6").
# `terraform test` resolves a single provider version per run, so per-major
# coverage lives here instead: this folder pins azurerm to 5.x and the matching
# provider-v4 folder pins 4.x. The shared CI "Validate examples" job runs
# `terraform init` + `terraform validate` once per examples/* folder, each
# resolving its own azurerm major — so a removed, renamed, or newly-required
# provider attribute fails validation in the folder for the major that dropped it.
#
# Keep this folder in sync with provider-v4; only the pinned major should differ.

terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

module "storage_account" {
  source = "../.."

  name                = "providerv5example"
  resource_group_name = "rg-provider-compat"
  location            = "westeurope"

  # Exercise the resources with azurerm 5.0 breaking changes so validate checks
  # their schema under the pinned provider major:
  #   storage_container / storage_share    -> storage_account_name removed
  #   storage_account_customer_managed_key -> key_* removed, use key_vault_key_id
  storage_containers  = { "container1" = {} }
  storage_file_shares = { "share1" = { quota = 5 } }

  cmk_key = {
    resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-provider-compat/providers/Microsoft.KeyVault/vaults/kv-compat/keys/cmk"
    versionless_id          = "https://kv-compat.vault.azure.net/keys/cmk"
  }
}
