locals {
  nfs_node_name    = "proxmox"
  nfs_vm_name      = "nfs"
  nfs_vm_id        = 114
  nfs_datastore_id = "local-zfs"

  nfs_os_disk_size_gb   = 16

  nfs_ip_address = "10.0.0.14/24"
  nfs_gateway    = "10.0.0.1"

  nfs_ssh_username = "db"
}

resource "proxmox_virtual_environment_vm" "nfs" {
  name        = local.nfs_vm_name
  description = "NFS server. Cloned from Debian 13 template. Managed by Terraform."
  tags        = ["terraform"]

  node_name = local.nfs_node_name
  vm_id     = local.nfs_vm_id
  machine   = "q35"

  clone {
    vm_id = local.template_vm_id
    full  = true
  }

  agent {
    enabled = true
    timeout = "60s"
  }

  # Force a hard stop instead of a graceful ACPI/agent-based shutdown on destroy.
  # Prevents terraform destroy from hanging if qemu-guest-agent isn't running yet.
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = local.nfs_datastore_id
    interface    = "scsi0"
    size         = local.nfs_os_disk_size_gb
    discard      = "on"
    iothread     = true
  }

  virtiofs {
    mapping       = "mediapool"
    cache         = "auto"
    expose_acl    = true
    expose_xattr  = true
  }

  virtiofs {
    mapping       = "datapool"
    cache         = "auto"
    expose_acl    = true
    expose_xattr  = true
  }

  network_device {
    bridge = local.bridge
  }

  vga {
    type = "serial0"
  }
  
  serial_device {}

  boot_order = ["scsi0"]

  initialization {
    datastore_id = local.nfs_datastore_id
    interface    = "ide2"

    vendor_data_file_id = proxmox_virtual_environment_file.generic_cloud_init_vendordata.id

    ip_config {
      ipv4 {
        address = local.nfs_ip_address
        gateway = local.nfs_gateway
      }
    }

    dns {
      servers = ["10.0.0.5", "10.0.0.22"]
    }

    user_account {
      username = "db"
      keys     = [local.ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }
#  lifecycle {
#    ignore_changes = [
#      initialization,
#    ]
#  }
}

