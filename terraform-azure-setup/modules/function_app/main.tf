resource "azurerm_storage_account" "storage" {
  name                     = "${var.name}storage"  # Ensure this is globally unique
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier            = "Standard"
  account_replication_type = "LRS"

  # Ensure the storage account name is lowercase and adheres to Azure's naming rules
  lifecycle {
    prevent_destroy = true  # Optional: Prevent accidental deletion
  }
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.name}-Plan"  # Plan name derived from the Function App name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_function_app" "function" {
  name                       = var.name  # Should be globally unique, set to "rsa_azure_function"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key  = azurerm_storage_account.storage.primary_access_key
  version                    = "~4"
  os_type                    = "linux"

  # You can add app settings here if needed
  app_settings = {
    "AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.storage.name};AccountKey=${azurerm_storage_account.storage.primary_access_key};EndpointSuffix=core.windows.net"
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"  # Or "node", depending on your function app runtime
  }
}

output "function_id" {
  value = azurerm_function_app.function.id
}
