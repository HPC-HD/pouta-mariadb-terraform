output volume_id {
  description = "the ID of the reserved storage volumne"
  value = openstack_blockstorage_volume_v3.volume.id
}
