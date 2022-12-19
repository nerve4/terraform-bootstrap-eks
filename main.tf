module "network" {
  source       = "./modules/aws-vpc"
  region       = var.region
  project_name = var.project_name
  environment  = var.environment
  maintainer   = var.maintainer

  vpc_cidr_block                  = var.vpc_cidr_block
  vpc_private_subnets_cidr_blocks = var.vpc_private_subnets_cidr_blocks
  vpc_public_subnets_cidr_blocks  = var.vpc_public_subnets_cidr_blocks
}

module "eks_cluster" {
  source       = "./modules/aws-eks"
  region       = var.region
  project_name = var.project_name
  environment  = var.environment
  maintainer   = var.maintainer

  vpc_cidr_block                  = module.network.vpc_id
  vpc_private_subnets_cidr_blocks = module.network.private_subnets
  vpc_public_subnets_cidr_blocks  = module.network.public_subnets
}
