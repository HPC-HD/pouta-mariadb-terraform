terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key = var.s3_access_key_id
  secret_key = var.s3_secret_access_key
  region = "us-east-1"
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true  
  endpoints {
    s3       = var.s3_endpoint
  }
}