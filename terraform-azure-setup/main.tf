provider "azurerm" {
  features {}

  # Uncomment these lines if you want to authenticate using a Service Principal
  # client_id       = "<YOUR_APP_ID>"
  # client_secret   = "<YOUR_PASSWORD>"
  # tenant_id       = "<YOUR_TENANT_ID>"
  # subscription_id  = "<YOUR_SUBSCRIPTION_ID>"
}


# Include Resource Group Module
module "resource_group" {
  source  = "./modules/resource_group"
  name    = "rsa"
  location = "East US"
}

# Include VNet Module
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
}

# Include NSG Module for Function App
module "function_nsg" {
  source              = "./modules/nsg"
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  name               = "rsaFunctionNSG"
}

# Include NSG Module for Bastion
module "bastion_nsg" {
  source              = "./modules/nsg"
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  name               = "rsaBastionNSG"
}

# Include Bastion Host Module
module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  vnet_name          = module.vnet.name
  bastion_nsg_id     = module.bastion_nsg.nsg_id
}

# Include Function App Module
module "function_app" {
  source              = "./modules/function_app"
  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  vnet_name          = module.vnet.name
  function_nsg_id    = module.function_nsg.nsg_id
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}
