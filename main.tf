variable "project_name" { }
variable "project_id" { }
variable "root_user" { }
variable "root_password" { }
variable "keypair" { }

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

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.project_name
  public_key = var.keypair
}

resource "openstack_compute_secgroup_v2" "ssh_mosh" {
    name = "SSH/MOSH"
    description = "SSH/MOSH"
    rule {
        from_port   = 22
        to_port     = 22
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }
    rule {
        from_port   = 60000
        to_port     = 61000
        ip_protocol = "udp"
        cidr        = "0.0.0.0/0"
    }
}

resource "openstack_compute_secgroup_v2" "mariadb" {
    name = "MariaDB"
    description = "MariaDB"
    rule {
        from_port   = 3306
        to_port     = 3306
        ip_protocol = "tcp"
        cidr        = "0.0.0.0/0"
    }
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
  image_name      = "Ubuntu-20.04"
  flavor_name     = "io.160GB"
  key_pair        = "${openstack_compute_keypair_v2.keypair.name}"
  security_groups = ["default",openstack_compute_secgroup_v2.ssh_mosh.name,openstack_compute_secgroup_v2.mariadb.name]
  network {
    name = var.project_id
  }
  user_data = templatefile("cloud-config.yaml", { project_name=var.project_name, root_user=var.root_user, root_password=var.root_password != "" ? var.root_password : random_password.root_password.result})
}

resource "openstack_networking_floatingip_v2" "floatip" {
  pool = "public"
}

output "ip-address" {
  value = openstack_networking_floatingip_v2.floatip.address
}

resource "openstack_compute_floatingip_associate_v2" "associate_ip" {
  floating_ip = openstack_networking_floatingip_v2.floatip.address
  instance_id = openstack_compute_instance_v2.server.id
}
