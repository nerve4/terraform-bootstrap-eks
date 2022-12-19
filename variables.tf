# -----------------------------------------------
# General for EKS Cluster
# -----------------------------------------------

variable "region" {
  type        = string
  description = "The AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name of the project/applicatrion, used by resources, vpc, etks, etc"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "maintainer" {
  type        = string
  description = "Name of the maintainer"
}

# -----------------------------------------------
# Network for EKS Cluster
# -----------------------------------------------

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets_cidr_blocks" {
  type        = set(string)
  description = "CIDR blocks dedicated for private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.vpc_private_subnets_cidr_blocks) > 1
    error_message = "At least two CIDR has to be given."
  }
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = set(string)
  description = "CIDR blocks dedicated for public subnets"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  validation {
    condition     = length(var.vpc_public_subnets_cidr_blocks) > 1
    error_message = "At least two CIDR has to be given."
  }
}

# -----------------------------------------------
# EKS Cluster
# -----------------------------------------------
