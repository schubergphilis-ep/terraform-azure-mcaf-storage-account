# Pin the test suite to the azurerm 4.x lower bound of the module's supported
# range (root terraform.tf: ">= 4, < 6"). `terraform test` resolves a single
# provider version for the whole run from the root module plus every fixture it
# loads, so constraining the version here keeps CI exercising azurerm 4.x.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
