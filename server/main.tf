resource "random_password" "mariadb_root_password" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  min_numeric      = 1
  override_special = "!#%&*()-_=+[]{}<>:?"
  count = var.mariadb_root_password == "" ? 1 : 0
}

resource "random_password" "cej_password" {
  length           = 16
  min_lower        = 1
  min_upper        = 1 
  min_special      = 1
  min_numeric      = 1
  override_special = "!#%&*()-_=+[]{}<>:?"
  count = var.cej_password == "" ? 1 : 0
}

resource "random_password" "cmapi_key" {
  length           = 16
  min_lower        = 1
  min_upper        = 1 
  min_special      = 1
  min_numeric      = 1
  override_special = "!#%&*()-_=+[]{}<>:?"
  count = var.cmapi_key == "" ? 1 : 0
}

locals {
  mariadb_root_password = var.mariadb_root_password != "" ? var.mariadb_root_password : one(random_password.mariadb_root_password[*].result)
  cej_password = var.cej_password != "" ? var.cej_password : one(random_password.cej_password[*].result)
  cmapi_key = var.cmapi_key != "" ? var.cmapi_key : one(random_password.cmapi_key[*].result)
}

resource "openstack_compute_volume_attach_v2" "va" {
  instance_id = openstack_compute_instance_v2.server.id
  volume_id   = var.volume_id
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
  user_data = templatefile("cloud-config.yaml", { 
    project_name=var.project_name, 
    mariadb_root_user=var.mariadb_root_user, 
    mariadb_root_password=local.mariadb_root_password, 
    cej_password=local.cej_password, 
    cmapi_key=local.cmapi_key, 
    s3_access_key_id=var.s3_access_key_id, 
    s3_bucket=var.s3_bucket, 
    s3_secret_access_key=var.s3_secret_access_key,
    s3_endpoint=var.s3_endpoint, 
    use_s3_storage=var.use_s3_storage
  })
}

resource "openstack_compute_floatingip_associate_v2" "associate_ip" {
  floating_ip = var.floating_ip
  instance_id = openstack_compute_instance_v2.server.id
}

