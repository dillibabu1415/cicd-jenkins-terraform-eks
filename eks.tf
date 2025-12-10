module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  

  cluster_name                   = local.name
 
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
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets


  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


eks_managed_node_groups_defaults = {
  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = ["m5.xlarge"]

  attach_cluster_primary_security_group = true
 
}

eks_managed_node_groups = {
  amonkincloud-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.large]"
      capacity_type  = "SPOT"

   tags = {
       ExtraTag = "Helloworld"  
    }
  }
}
}
