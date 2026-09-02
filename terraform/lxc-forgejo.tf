resource "proxmox_virtual_environment_container" "forgejo_lxc" {
  node_name     = "proxmox"
  vm_id         = 132
  unprivileged  = true
  start_on_boot = false
  protection    = true

  startup {
    down_delay = -1
    order      = 8
    up_delay   = -1
  }


  initialization {
    hostname = "forgejo"

    ip_config {
      ipv4 {
        address = "10.0.0.32/24"
        gateway = "10.0.0.1"
      }
    }

    user_account {
      password = data.bitwarden-secrets_secret.lxc_root_password.value
      keys     = [data.bitwarden-secrets_secret.ssh_pub_key2.value]
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
    swap      = 512
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 16
  }

  operating_system {
    type             = "debian"
    template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  }

  features {
    nesting = true
  }
  
  lifecycle {
    ignore_changes = [
      started,
    ]
  }
}