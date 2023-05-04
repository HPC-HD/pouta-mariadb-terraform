output "ssh_mosh_secgroup_id" {
  description = "The ID of the security group exposing SSH/MOSH ports"
  value = openstack_networking_secgroup_v2.ssh_mosh.id
}

output "mariadb_secgroup_id" {
  description = "The ID of the security group exposing MariaDB ports"
  value = openstack_networking_secgroup_v2.mariadb.id
}

output "floating_ip" {
  description = "The floating IP reserved"
  value = openstack_networking_floatingip_v2.floatip.address
}