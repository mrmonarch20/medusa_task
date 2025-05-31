terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "medusa-terraform-state-us-east-1"
    key    = "medusa/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
