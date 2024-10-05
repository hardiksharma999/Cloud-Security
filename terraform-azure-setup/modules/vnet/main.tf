resource "azurerm_virtual_network" "this" {
  name                = "${var.name}VNet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  name                 = "${var.name}Subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

output "subnet_id" {
  value = azurerm_subnet.this.id
}
