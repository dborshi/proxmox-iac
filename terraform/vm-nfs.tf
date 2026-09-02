locals {
  nfs_shares = yamldecode(
    file("${path.root}/../ansible/inventory/group_vars/nfs/nfs_shares.yml")
  ).nfs_shares

  nfs_data_disks = {
    for d in local.nfs_shares : d.interface => {
      serial       = d.serial
      size         = d.size
      datastore_id = d.datastore_id
      backup       = d.backup
    }
  }
}

resource "proxmox_virtual_environment_vm" "nfs" {
  name        = "nfs"
  description = "NFS server. Cloned from Debian 13 template. Managed by Terraform."
  tags        = ["terraform"]

  node_name = "proxmox"
  vm_id     = 114
  machine   = "q35"

  scsi_hardware = "virtio-scsi-single"

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

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 16
    discard      = "on"
    iothread     = true
  }

  dynamic "disk" {
    for_each = local.nfs_data_disks
    content {
      datastore_id = disk.value.datastore_id
      interface    = disk.key
      size         = disk.value.size
      serial       = disk.value.serial
      discard      = "on"
      iothread     = true
      backup       = disk.value.backup
    }
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
    datastore_id = "local-zfs"
    interface    = "ide2"

    vendor_data_file_id = proxmox_virtual_environment_file.generic_cloud_init_vendordata.id

    ip_config {
      ipv4 {
        address = "10.0.0.14/24"
        gateway = "10.0.0.1"
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

  # The data disks are attributes of this resource, so destroying the VM
  # destroys them. This is the only guard.
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      initialization,
      started,
    ]
  }
}
