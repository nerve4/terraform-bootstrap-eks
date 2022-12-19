variable "region" {
  type        = string
  description = "The AWS region."
}

variable "project_name" {
  type        = string
  description = "Name of the project/applicatrion, used by resources, vpc, etks, etc."
}

variable "environment" {
  type        = string
  description = "Name of the environment."
}

variable "maintainer" {
  type        = string
  description = "Name of the maintainer."
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "vpc_private_subnets_cidr_blocks" {
  type        = set(string)
  description = "CIDR blocks dedicated for private subnets."
}

variable "vpc_public_subnets_cidr_blocks" {
  type        = set(string)
  description = "CIDR blocks dedicated for public subnets."
}
