variable "vnet_full_name" {
  type = string
  description = <<DESCRIPTION
  (Optionl) The name of the vnet to create.
  DESCRIPTION
  nullable = false
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "resource_group_name" {
  type = string
}

variable "vnet_address_spaces" {
  type = list(string)
}