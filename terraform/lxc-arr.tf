resource "proxmox_virtual_environment_container" "arr_lxc" {
  node_name     = "proxmox"
  vm_id         = 155
  unprivileged  = true
  start_on_boot = true

  startup {
    down_delay = -1
    order      = 6
    up_delay   = -1
  }


  initialization {
    hostname = "arr-suite"

    ip_config {
      ipv4 {
        address = "10.0.0.55/24"
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
    swap      = 2048
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 20
  }

  mount_point {
    volume            = "nvmepool:subvol-155-disk-0"
    size              = "64G"
    path              = "/opt/appdata"
    backup            = true
  }

  mount_point {
    volume            = "/srv/mediapool"
    path              = "/mnt/arr"
    backup            = false
  }

  device_passthrough {
    deny_write = false
    gid        = 992
    mode       = "0660"
    path       = "/dev/dri/renderD128"
    uid        = 0
  }
  
  device_passthrough {
    deny_write = false
    gid        = 44
    mode       = "0660"
    path       = "/dev/dri/card1"
    uid        = 0
  }

  operating_system {
    type             = "debian"
    template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  }

  features {
    nesting = true
  }
}