variable "proxmox_username" {
  default = env("PROXMOX_USERNAME")
}

variable "proxmox_password" {
  default = env("PROXMOX_PASSWORD")
}

source "proxmox-iso" "ubuntu" {
  boot_command = [
    "<esc><wait><esc><wait><f6><wait><esc><wait><bs><bs><bs><bs><bs> autoinstall ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/cloud-init/ubuntu-proxmox/<enter>"
  ]
  boot_wait                = "5s"
  cores                    = 2
  http_directory           = "${path.root}"
  # using Windows: select from output of 'ipconfig /all'
  http_interface           = "vEthernet (external)"
  insecure_skip_tls_verify = true
  iso_file                 = "local:iso/ubuntu-20.04.3-live-server-amd64.iso"
  memory                   = 4096
  node                     = "proxmox"
  password                 = "${var.proxmox_password}"
  proxmox_url              = "https://192.168.1.4:8006/api2/json"
  ssh_password             = "packer"
  ssh_timeout              = "20m"
  ssh_username             = "packer"
  template_name            = "ubuntu-base"
  unmount_iso              = true
  username                 = "${var.proxmox_username}"
  vm_name                  = "ubuntu"
  disks {
    storage_pool      = "local-lvm"
    storage_pool_type = "lvm-thin"
    disk_size         = "30G"
    format            = "raw"
  }
  network_adapters {
    bridge = "vmbr0"
    model = "virtio"
  }
}

build {
  sources = ["source.proxmox-iso.ubuntu"]
  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S bash '{{.Path}}'"
    script          = "${path.root}/scripts/ubuntu-proxmox.sh"
  }
}
