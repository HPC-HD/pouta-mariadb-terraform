output "mariadb_root_password" {
  sensitive = true
  value = local.mariadb_root_password
}

output "cej_password" {
  sensitive = true
  value = local.cej_password
}

output "cmapi_key" {
  sensitive = true
  value = local.cmapi_key
}
