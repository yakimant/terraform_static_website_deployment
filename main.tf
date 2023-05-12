terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66"
    }
  }

  cloud {
    organization = "ORGANISATION"
    workspaces {
      tags = ["app:website"]
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.workspace_iam_roles[terraform.workspace]
  }
}

module "ec2_website" {
  source               = "./modules/terraform-aws-ec2_website"
  ssh_public_key       = var.ssh_public_keys[terraform.workspace]
  ssh_private_key_path = var.ssh_private_key_paths[terraform.workspace]
}

module "ec2_website_deploy" {
  source               = "./modules/terraform-aws-ec2_website_deploy"
  ssh_private_key_path = var.ssh_private_key_paths[terraform.workspace]
  website_public_ip    = module.ec2_website.ec2_public_ip
  website_root         = var.website_root
}

module "s3_website" {
  source = "./modules/terraform-aws-s3_website"
}

module "s3_website_deploy" {
  source       = "./modules/terraform-aws-s3_website_deploy"
  s3_bucket_id = module.s3_website.bucket_id
  website_root = var.website_root
}