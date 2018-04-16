# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "tfrg" {
  name     = "${var.prefix}-rg"
  location = "${var.location}"

  tags {
    environment = "${var.tag}"
  }
}

# Create virtual network
data "azurerm_virtual_network" "tfvnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = "${azurerm_resource_group.tfrg.name}"
}

resource "azurerm_subnet" "tfwafnet" {
  name                 = "waf-net"
  virtual_network_name = "${data.azurerm_virtual_network.tfvnet.name}"
  resource_group_name  = "${azurerm_resource_group.tfrg.name}"
  address_prefix       = "10.0.10.0/24"
}
