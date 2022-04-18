provider "aws" {
  region = var.region
  profile = var.profile
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "test-new-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnet_ids         = var.private_subnets
  cluster_endpoint_private_access = true
  
  tags = {
    Environment = "test"
  }

  vpc_id = var.vpc_id

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
    instance_types = ["t3.small"]
  }

  cluster_security_group_additional_rules = {
    inress_kubeapi_ports_tcp = {
      description                = "To 443"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_security_group_id = "sg-06b59addcb4098e92"
    }
  }
  eks_managed_node_groups = {
    es = {
      desired_size = 2
      max_size     = 10
      min_size     = 1
      key_name = "my"
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        Environment = "test"
      }
      additional_tags = {
        ExtraTag = "es"
      }
      # taints = [
      #   {
      #     key    = "dedicated"
      #     value  = "gpuGroup"
      #     effect = "NO_SCHEDULE"
      #   }
      # ]
    }
  }

  # Create security group rules to allow communication between pods on workers and pods in managed node groups.
  # Set this to true if you have AWS-Managed node groups and Self-Managed worker groups.
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1089

  # worker_create_cluster_primary_security_group_rules = true

  # worker_groups_launch_template = [
  #   {
  #     name                 = "worker-group-1"
  #     instance_type        = "t3.small"
  #     asg_desired_capacity = 2
  #     public_ip            = true
  #   }
  # ]

  # map_roles    = var.map_roles
  # map_users    = var.map_users
  # map_accounts = var.map_accounts
}
