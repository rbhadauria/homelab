

resource "random_password" "ubuntu_vm_password" {
  length           = 8
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "omv-nfs"
  node_name    = data.proxmox_virtual_environment_node.pve-large.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    chpasswd:
      list: |
        ubuntu:${random_password.ubuntu_vm_password.result}
      expire: false
    package_update: true
    packages:
      - qemu-guest-agent
    runcmd:
      - systemctl enable --now qemu-guest-agent  
    users:
      - default
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    EOF

    file_name = "vm.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "VMs" {
  for_each    = { for vm in var.vm_details : vm.name => vm }
  description = "Managed by Terraform"
  tags        = [each.value.name]
  node_name   = each.value.node_name
  name        = each.value.name

  agent {
    enabled = "true"
  }
  cpu {
    cores = each.value.cpu
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = each.value.ram
    floating  = each.value.ram
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu.id
    interface    = "scsi0"
    size         = each.value.disk_size
    ssd          = "true"
  }

  dynamic "disk" {
    for_each = lookup(each.value, "disk_path", "") != "" ? [each.value] : []
    content {
      datastore_id      = ""
      path_in_datastore = each.value.disk_path
      interface         = "scsi1"
      file_format       = "raw"
      backup            = false
    }
  }
  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.${90 + index(var.vm_details, each.value)}/24"
        gateway = "192.168.1.1"

      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

  }
  stop_on_destroy = true

  network_device {

  }
}

