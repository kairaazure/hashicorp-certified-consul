variable "resource_group_name" {
  description = "Set the name of resource group"
}
variable "resource_group_location" {
  description = "Set the location on which resources are provisioned"
}
variable "tags" {
  type = map(string)
  default = {
    Owner       = "KirtiBansal"
    Environment = "Testing"
    CreatedBy   = "Terraform"
  }
}

