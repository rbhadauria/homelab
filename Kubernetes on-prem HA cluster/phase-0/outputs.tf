output "ubuntu_vm_password" {
  value     = random_password.ubuntu_vm_password.result
  sensitive = true
}

output "ubuntu_vm_private_key" {
  value     = tls_private_key.ubuntu_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ubuntu_vm_key.public_key_openssh
}


output "vms_info" {
  value = [
    for vm in proxmox_virtual_environment_vm.VMs :
    {
      name = vm.name
      ip   = vm.ipv4_addresses[1][0] # or use agent IP if guest agent enabled
    }
  ]
  description = "List of VMs with their names and IPs"
}
