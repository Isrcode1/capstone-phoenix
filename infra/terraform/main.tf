terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "phoenix-tfstate-israel"
    key            = "capstone/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = "terraform"
}

module "network" {
  source       = "./modules/network"
  vpc_cidr     = var.vpc_cidr
  subnet_cidrs = var.subnet_cidrs
  aws_region   = var.aws_region
  project_name = var.project_name
}

module "security" {
  source       = "./modules/security"
  vpc_id       = module.network.vpc_id
  my_ip        = var.my_ip
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "compute" {
  source            = "./modules/compute"
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.subnet_ids
  security_group_id = module.security.security_group_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  ami_id            = var.ami_id
  project_name      = var.project_name
  master_count      = 1
  worker_count      = 2
}
