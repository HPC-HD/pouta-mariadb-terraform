output s3_access_key_id {
    description = "The S3 access key id created"
    value = openstack_identity_ec2_credential_v3.s3_key.access
}
output s3_secret_access_key {
    description = "The S3 secret access key created"
    sensitive = true
    value = openstack_identity_ec2_credential_v3.s3_key.secret
}