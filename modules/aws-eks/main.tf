provider "aws" {
  region = var.region
}

locals {
  cluster_name = "${var.environment}-${var.project_name}-cluster"
  tags = {
    Name        = var.project_name
    Environment = var.environment
    Maintainer  = var.maintainer
  }
}

# -----------------------------------------------
# EKS Module
# -----------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.3.0"

  cluster_name                   = local.cluster_name
  cluster_endpoint_public_access = true
  cluster_version                = "1.24"

  vpc_id     = var.vpc_cidr_block
  subnet_ids = var.vpc_private_subnets_cidr_blocks

  # Default Cluster Addons
  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]

    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = [aws_security_group.additional.id]
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 5
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }

      update_config = {
        max_unavailable_percentage = 30
      }

      tags = local.tags
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
        }
      ]

      tags = local.tags

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  tags = local.tags
}

# -----------------------------------------------
# Kubernetes
# -----------------------------------------------

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# -----------------------------------------------
# IAM Policy
# -----------------------------------------------

resource "aws_iam_policy" "additional" {
  name = "${var.project_name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# -----------------------------------------------
# Security Groups
# -----------------------------------------------

resource "aws_security_group" "additional" {
  name_prefix = "${var.project_name}-additional"
  vpc_id      = var.vpc_cidr_block

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = merge(local.tags, { Name = "${var.project_name}-additional" })
}
