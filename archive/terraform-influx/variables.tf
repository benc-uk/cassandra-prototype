variable "location" {
  type    = string
  default = "ukwest"
}

variable "rg_name" {
  type    = string
  default = "loadtesting"
}

variable "influxdb_vm_size" {
  type    = string
  default = "Standard_D8s_v3"
}
