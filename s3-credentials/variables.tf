variable "s3_bucket" { 
    description = "S3 bucket to use (if S3 backend storage used)"
    default = "" 
}

variable "s3_endpoint" { 
    description = "S3 endpoint address (if S3 backend storage used)"
    default = "a3s.fi"
}

variable "s3_access_key_id" { 
    description = "S3 access key id"
    default = " "
}

variable "s3_secret_access_key" { 
    description = "S3 secret access key"
    default = " "
}