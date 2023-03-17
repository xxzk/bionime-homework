# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_availability_zones" "available" {}


locals {
  cluster_name = "my-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "eks-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  #enable_nat_gateway   = true
  #single_nat_gateway   = true
  #enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

   eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t2.micro"]
    iam_role_attach_cni_policy = true
  }

   eks_managed_node_groups = {
    my_node_group = {
      min_size  = 1
      max_size  = 1
      desired_size = 1
      use_custom_launch_template = false
      disk_size = 20
      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = var.ec2_ssh_key
        #source_security_group_ids = [aws_security_group.remote_access.id]
      }
    }

}
}