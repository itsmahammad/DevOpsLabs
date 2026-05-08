variable "project_name" {
  type    = string
  default = "casp"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "admin_public_ip" {
  type        = string
  description = "Your public IP allowed to SSH into Ops VM"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_casp.pub"
}
