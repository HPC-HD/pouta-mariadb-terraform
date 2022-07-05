variable "project_name" { }
variable "project_id" { }
variable "volume_id" { }
variable "floating_ip" { }
variable "ssh_mosh_secgroup_id" { }
variable "mariadb_secgroup_id" { }

variable "vm_flavour" {
    default = "io.160GB"
}

data "openstack_compute_keypair_v2" "keypair" {
  name = var.project_name
}

resource "openstack_compute_volume_attach_v2" "va" {
  instance_id = openstack_compute_instance_v2.server.id
  volume_id   = var.volume_id
  device = "/dev/vdc"
}

resource "openstack_compute_instance_v2" "server" {
  name            = "${var.project_name}-mariadb"
  image_name      = "Ubuntu-20.04"
  flavor_name     = var.vm_flavour
  key_pair        = data.openstack_compute_keypair_v2.keypair.name
  security_groups = ["default",var.ssh_mosh_secgroup_id,var.mariadb_secgroup_id]
  network {
    name = var.project_id
  }
  user_data = templatefile("cloud-config.yaml",{project_name=var.project_name}) 
}

resource "openstack_compute_floatingip_associate_v2" "associate_ip" {
  floating_ip = var.floating_ip
  instance_id = openstack_compute_instance_v2.server.id
}
