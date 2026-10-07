# Provider-compatibility test root — azurerm 4.x.
#
# The module supports a range of azurerm majors (root terraform.tf: ">= 4, < 6").
# `terraform test` resolves a single provider version per working directory, so
# each major is exercised from its own folder: this one pins 4.x, provider-v5
# pins 5.x. Run them independently — `terraform -chdir=tests/provider-v4 init`
# then `terraform -chdir=tests/provider-v4 test`.
#
# The *.tftest.hcl files here are intentionally identical to provider-v5's; only
# the pinned major below differs.
terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
