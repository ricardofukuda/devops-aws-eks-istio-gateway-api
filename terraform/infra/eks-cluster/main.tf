locals {
  cluster_name = "eks-${var.env}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.37.2"

  create = true

  cluster_name    = local.cluster_name
  cluster_version = "1.34"

  cluster_endpoint_public_access       = true # TEST ONLY
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["${chomp(data.http.icanhazip.response_body)}/32"] # restrict to my current public ip #TEST #TODO

  control_plane_subnet_ids = module.vpc.private_subnets

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [] # empty to force each nodegroup to configure it

  iam_role_use_name_prefix = true
  iam_role_name            = local.cluster_name

  bootstrap_self_managed_addons = true

  node_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name
  }

  iam_role_additional_policies = {
    "session_manager" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true # ENABLE_PREFIX_DELEGATION: increase the max amount of Pods per node by increasing the max amount of IPs for each ENI attached to the node. Risk: you should recreate all nodegroups to avoid conflicts with prefix and non-prefix ips.
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
        }
      })
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_role.iam_role_arn
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2023_x86_64_STANDARD"

    #subnet_ids = module.vpc.private_subnets # by default, we use private subnets
    subnet_ids = [data.aws_subnet.us-east-1d.id]

    network_interfaces = [
      {
        associate_public_ip_address = false # by default, we disable public IPs
      }
    ]
  }

  eks_managed_node_groups = {
    infra = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      disk_size = 20

      instance_types = ["t3a.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "infra"
      }

      #      taints = [{
      #        "key" = "role"
      #        "value" = "infra"
      #        "operator": "Equal"
      #        "effect" = "NoSchedule"
      #      }]
    }
  }

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  create_kms_key                  = false # TEST ONLY
  kms_key_deletion_window_in_days = 7
  cluster_encryption_config       = {}

  create_cloudwatch_log_group = false # disable cloudwatch logging
  cluster_enabled_log_types   = []    # disable cloudwatch logging

  node_security_group_additional_rules = {
    cluster_control_plane_to_nodes = { # required to make webhooks work for istio-ingress-gateway!
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
      description                   = "cluster_control_plane_to_nodes"
    }
  }

  depends_on = [module.nat-instance]
}
