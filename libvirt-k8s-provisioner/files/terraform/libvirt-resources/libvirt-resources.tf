variable "domain" { default = "k8s.lab" }
variable "network_cidr" {
  type = list
  default = ["192.168.100.0/24"]
}
variable "cluster_name" { default = "k8s" }
variable "libvirt_pool_path" { default = "/var/lib/libvirt/images" }
variable "additional_cluster" { default = "k8s.lab" }
variable "create_network" {
  description = "If set to true, the network will be created"
  type = bool
  default = true
}
variable network_name { default = "k8s" }

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "cluster" {
  name = var.cluster_name
  type = "dir"
  path = "${var.libvirt_pool_path}/${var.cluster_name}"
}

resource "libvirt_network" "kube_network" {
  count = var.create_network ? 1 : 0
  autostart = true
  name = var.network_name
  mode = "route"
  domain = var.domain
  addresses = var.network_cidr
  bridge = var.cluster_name

  dns {
    enabled = true
    local_only = true
  }

  dnsmasq_options {
    options  {
        option_name = "server"
        option_value = "/${var.network_name}/${cidrhost(var.network_cidr[0],1)}"
      }
  }
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source = "registry.terraform.io/dmacvicar/libvirt"
      version = "0.7.0"
    }
  }
}

