resource "proxmox_virtual_environment_vm" "arr" {
  node_name   = "proxmox"
  name        = "arr-suite"
  vm_id       = 160

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 16384
    floating  = 0
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = "local:import/debian-13-generic-amd64.qcow2"
    interface    = "virtio0"
    size         = 64
    discard      = "on"
    iothread     = true
    file_format  = "raw"
  }

  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = false
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
    trim    = true
  }

  initialization {
    type         = "nocloud"
    datastore_id = "local-zfs"

    ip_config {
        ipv4 {
        address = "10.0.0.60/24"
        gateway = "10.0.0.1"
        }
    }

    dns {
        servers = ["10.0.0.5", "10.0.0.22"]
    }

    user_account {
      password = data.bitwarden-secrets_secret.vm_root_password.value
      keys     = [data.bitwarden-secrets_secret.ssh_pub_key2.value]
    }
  }
  lifecycle {
    ignore_changes = [
      description,
      tags,
      virtiofs,
      initialization,
    ]
  }
}
