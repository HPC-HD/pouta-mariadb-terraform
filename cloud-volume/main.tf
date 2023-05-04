resource "openstack_blockstorage_volume_v3" "volume" {
    name  = "${var.project_name}-mariadb"
    size = var.storage_size
}
