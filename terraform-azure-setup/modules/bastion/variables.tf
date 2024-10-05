variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location for the Bastion Host."
  type        = string
}

variable "name" {
  description = "The name of the Bastion Host."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where Bastion will be deployed."
  type        = string
}
