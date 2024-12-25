// Packer : https://www.packer.io/

packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      version = "~> 1"
      source = "github.com/hashicorp/vagrant"
    }
  }
}
source "qemu" "ubuntu24" {
  boot_wait = "2s"
  boot_command = ["e<wait><down><down><down><end> autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<F10>"]
  headless = false

  communicator = "ssh"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "30m"

  # qemu boilerplate
  accelerator       = "kvm"
  cpus              = 2
  disk_interface    = "virtio-scsi"
  disk_size         = "6G"
  disk_compression  = true
  format            = "qcow2"
  machine_type      = "q35"
  memory            = 4096
  net_device        = "virtio-net"
  output_directory  = "output/packer"
  shutdown_command  = "sudo -S shutdown -P now"
  efi_boot          = false
  qemuargs = [
    ["-cpu", "host"]
  ]
  iso_url      = "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
  iso_checksum = "e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"

  http_directory = "http"
}

build {
  sources = ["source.qemu.ubuntu24"]
  provisioner "shell" {
    execute_command="sudo -S env {{ .Vars }} {{ .Path }}"
    scripts = [
      "scripts/packer.sh"
    ]
  }
  post-processor "vagrant" {
    keep_input_artifact = true
    provider_override   = "libvirt"
    output = "output/packer/ubuntu24.box"
  }
}
