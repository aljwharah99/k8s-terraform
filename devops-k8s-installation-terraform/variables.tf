variable "prefix" {}

variable "location" {}

variable "vm_size" {
  default = "Standard_A2_v2"
}

variable "default_node_pool_name" {}

variable "database_server_name" {}

variable "administrator_login" {}

variable "administrator_login_password" {}

variable "db_name" {}

variable "dns_zone_name" {}
