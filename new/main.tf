variable "project_name" { }
variable "project_id" { }
variable "root_user" { }
variable "root_password" { }
variable "floating_ip" { }
variable "ssh_mosh_secgroup_id" { }
variable "mariadb_secgroup_id" { }

resource "random_password" "root_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

output "root_password" {
  sensitive = true
  value = var.root_password != "" ? var.root_password : random_password.root_password.result
}

variable "storage_size"  {
    type = number
    default = 256
}

variable "vm_flavour" {
    default = "io.160GB"
}

resource "openstack_blockstorage_volume_v3" "volume" {
    name  = "${var.project_name}-mariadb"
    size = var.storage_size
}

resource "openstack_compute_volume_attach_v2" "va" {
  instance_id = "${openstack_compute_instance_v2.server.id}"
  volume_id   = "${openstack_blockstorage_volume_v3.volume.id}"
  device = "/dev/vdc"
}

resource "openstack_compute_instance_v2" "server" {
  name            = "${var.project_name}-mariadb"
  image_name      = "Ubuntu-22.04"
  flavor_name     = var.vm_flavour
  key_pair        = var.project_name
  security_groups = ["default",var.ssh_mosh_secgroup_id,var.mariadb_secgroup_id]
  network {
    name = var.project_id
  }
  user_data = templatefile("cloud-config.yaml", { project_name=var.project_name, root_user=var.root_user, root_password=var.root_password != "" ? var.root_password : random_password.root_password.result})
}

resource "openstack_compute_floatingip_associate_v2" "associate_ip" {
  floating_ip = var.floating_ip
  instance_id = openstack_compute_instance_v2.server.id
}

output volume_id {
  value = openstack_blockstorage_volume_v3.volume.id
}
