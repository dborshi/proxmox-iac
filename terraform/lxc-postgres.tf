resource "proxmox_virtual_environment_container" "postgres_lxc" {
  node_name     = "proxmox"
  vm_id         = 115
  unprivileged  = true
  start_on_boot = true

  startup {
    down_delay = -1
    order      = 1
    up_delay   = -1
  }

  initialization {
    hostname = "postgres"
    
    ip_config {
      ipv4 {
        address = "10.0.0.15/24"
        gateway = "10.0.0.1"
      }
    }

    user_account {
      password = data.bitwarden-secrets_secret.lxc_root_password.value
      keys     = [data.bitwarden-secrets_secret.ssh_pub_key2.value]
    }

  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
    swap      = 1024
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 20
  }

  mount_point {
    volume       = "nvmepool"
    size         = "50G"
    path         = "/var/lib/postgresql"
    backup       = true
  }
  
  operating_system {
  type             = "debian"
  template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  }

  features {
    nesting = true
  }
}