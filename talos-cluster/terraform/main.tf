locals {
  nodes = {
    talos-cp-1 = { id = 1001, ip = "10.0.0.41", cores = 3, mem = 8192, data_disk = null }
    talos-wk-1 = { id = 1002, ip = "10.0.0.42", cores = 4, mem = 8192, data_disk = { datastore = "nvmepool", size = 128, path = "vm-1002-disk-0" } }
    talos-wk-2 = { id = 1003, ip = "10.0.0.43", cores = 4, mem = 8192, data_disk = { datastore = "nvmepool", size = 128, path = "vm-1003-disk-0" } }
  }
}

resource "proxmox_virtual_environment_vm" "talos_nodes" {
  for_each  = local.nodes
  name      = each.key
  node_name = "proxmox"
  vm_id     = each.value.id

  clone {
    vm_id = 9000
    full  = true
  }

  cpu     {
    cores = each.value.cores
    type  = "host"
    }
  memory  { dedicated = each.value.mem }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 50
    ssd          = true
    backup       = true
    cache        = "none"
    aio          = "io_uring"
    discard      = "on"
    iothread     = true
  }

  dynamic "disk" {
    for_each = each.value.data_disk == null ? [] : [each.value.data_disk]
    content {
      datastore_id      = disk.value.datastore
      path_in_datastore = disk.value.path
      interface         = "scsi1"
      size              = disk.value.size
      file_format       = "raw"
      ssd               = true
      backup            = true
      cache             = "none"
      aio               = "io_uring"
      discard           = "on"
      iothread          = true
    }
  }

  network_device { bridge = "vmbr0" }
}