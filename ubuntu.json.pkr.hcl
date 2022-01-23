variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "20000"
}

variable "iso_checksum" {
  type    = string
  default = "md5:8df52f27204c37a50a169989fb019188"
}

variable "iso_url" {
  type    = string
  default = "file://D:/isos/ubuntu-20.04.3-live-server-amd64.iso"
}

variable "memory" {
  type    = string
  default = "2048"
}

source "hyperv-iso" "ubuntu" {
  # need to double escape the ';' or else grub will treat it as the end of the command
  # found by checking /var/log/syslog. http option was missing in cmdline
  boot_command         = [
    "<esc><esc><esc><esc><wait>",
    "linux /casper/vmlinuz quiet autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/cloud-init/ubuntu/<enter>",
    "initrd /casper/initrd<enter>",
    "boot<enter>"
  ]
  boot_wait            = "1s"
  communicator         = "ssh"
  cpus                 = "${var.cpus}"
  disk_block_size      = "1"
  disk_size            = "${var.disk_size}"
  enable_secure_boot   = false
  generation           = "2"
  guest_additions_mode = "enable"
  http_directory       = "${path.root}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.memory}"
  output_directory     = "${path.root}/output-ubuntu"
  shutdown_command     = "echo 'packer' | sudo -S -E shutdown -P now"
  ssh_password         = "packer"
  ssh_timeout          = "60m"
  ssh_username         = "packer"
  vm_name              = "ubuntu-build"
}

build {
  sources = ["source.hyperv-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S bash '{{.Path}}'"
    script          = "${path.root}/scripts/ubuntu.sh"
  }
}
