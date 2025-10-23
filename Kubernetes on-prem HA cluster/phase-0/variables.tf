variable "virtual_environment_endpoint" {
  description = "The Proxmox VE API endpoint URL."
  type        = string
}

variable "virtual_environment_username" {
  description = "The username for Proxmox VE authentication."
  type        = string
}

variable "virtual_environment_password" {
  description = "The password for Proxmox VE authentication."
  type        = string
}

variable "vm_details" {
  description = "Defines the location and configuration of VMs"
  type = list(object({
    name      = string
    node_name = string
    cpu       = number
    ram       = number
  }))
}
