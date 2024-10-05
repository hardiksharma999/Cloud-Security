resource "azurerm_public_ip" "bastion_ip" {
  name                = "${var.name}-PublicIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                      = "configuration"
    subnet_id                = var.subnet_id
    public_ip_address_id     = azurerm_public_ip.bastion_ip.id
  }
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion_ip.ip_address
}
