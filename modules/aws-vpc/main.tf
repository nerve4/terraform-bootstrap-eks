provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tags = {
    Name        = var.project_name
    Environment = var.environment
    Maintainer  = var.maintainer
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr_block

  azs                                  = data.aws_availability_zones.available.names
  private_subnets                      = var.vpc_private_subnets_cidr_blocks
  public_subnets                       = var.vpc_public_subnets_cidr_blocks
  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_dns_hostnames                 = true
  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  tags = local.tags

  public_subnet_tags = {
    Name                     = "${var.project_name}-public-subnet"
    Environment              = var.environment
    Maintainer               = var.maintainer
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    Name                              = "${var.project_name}-private-subnet"
    Environment                       = var.environment
    Maintainer                        = var.maintainer
    "kubernetes.io/role/internal-elb" = "1"
  }
}
