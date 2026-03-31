terraform {
  required_version = ">= 1.9"
}

module "storage_account" {
  source = "../.."

  name                              = "saprovisionedv2"
  resource_group_name               = "rg-example"
  location                          = "West Europe"
  account_kind                      = "FileStorage"
  account_tier                      = "Premium"
  account_replication_type          = "LRS"
  provisioned_billing_model_version = "V2"

  network_configuration = {
    ip_rules = ["123.123.123.123"]
  }

  storage_file_shares = {
    "share1" = {
      access_tier = "Premium"
      quota       = 100
    }
  }

  share_properties = {
    smb = {
      multichannel_enabled = true
      versions             = ["SMB3.1.1"]
    }
  }
}
