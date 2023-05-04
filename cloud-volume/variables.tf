variable "project_name" { 
    description = "The name of the project, to be used in naming resources"
}

variable "storage_size"  {
    description = "The size of the storage in megabytes"
    type = number
    default = 256
}
