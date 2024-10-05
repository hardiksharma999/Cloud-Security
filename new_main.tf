
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# Step 1: Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rsa"
  location = "East US"
}

# Step 2: Create Virtual Network and Subnet
resource "azurerm_virtual_network" "main" {
  name                = "rsa_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "rsa_Subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Step 3: Define Network ACLs
resource "azurerm_network_security_group" "main" {
  name                = "rsa_NSG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Add inbound security rule for HTTP
resource "azurerm_network_security_rule" "http" {
  name                        = "Allow-HTTP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.main.name
}

# Step 4: Define Routes
resource "azurerm_route_table" "main" {
  name                = "rsa_RouteTable"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Step 5: Create Azure Function App
resource "azurerm_storage_account" "main" {
  name                     = "rssstorageaccount" # Must be globally unique
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "main" {
  name                = "rsa_functionplan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku {
    tier     = "Basic"
    size     = "B1"
  }
}

resource "azurerm_function_app" "main" {
  name                       = "rsa_functionapp" # Must be globally unique
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  storage_account_name       = azurerm_storage_account.main.name
  app_service_plan_id        = azurerm_app_service_plan.main.id
  version                    = "~3"
  os_type                    = "windows"
}

# Step 6: Set Up Bastion Host
resource "azurerm_public_ip" "bastion" {
  name                = "rsa_BastionIP"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku {
    name = "Standard"
  }
  allocation_method = "Static"
}

resource "azurerm_bastion_host" "main" {
  name                = "rsa_BastionHost"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                 = "MyBastionIPConfig"
    subnet_id            = azurerm_subnet.main.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}