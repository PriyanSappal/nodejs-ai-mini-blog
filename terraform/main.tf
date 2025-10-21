provider "aws" {
  region = var.aws_region
}


module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "ssm" {
  source = "./modules/ssm"
}

module "ecs" {
  source              = "./modules/ecs"
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  cluster_name        = "devops-mini-blog-cluster"
  ecr_repository      = module.ecr.repository_url
  ssm_parameter_names = module.ssm.parameter_names
  container_port      = var.app_container_port
}

