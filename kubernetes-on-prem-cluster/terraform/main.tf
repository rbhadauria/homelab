terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment_endpoint

  username      = var.virtual_environment_username
  password      = var.virtual_environment_password
  random_vm_ids = "true"

}

data "proxmox_virtual_environment_node" "pve-large" {
  node_name = "pve-large"
}

data "proxmox_virtual_environment_node" "pve-small" {
  node_name = "pve-small"
}

resource "proxmox_virtual_environment_download_file" "ubuntu" {
  content_type = "import"
  datastore_id = "omv-nfs"
  node_name    = data.proxmox_virtual_environment_node.pve-large.node_name
  file_name    = "ubuntu-24.04-amd64.qcow2"
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  overwrite    = false
}

