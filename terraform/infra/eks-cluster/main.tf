locals {
  cluster_name = "eks-${var.env}"
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.23.0"

  create = true

  name    = local.cluster_name
  kubernetes_version = "1.36"

  endpoint_public_access       = true # TEST ONLY
  endpoint_private_access      = true
  endpoint_public_access_cidrs = ["${chomp(data.http.icanhazip.response_body)}/32"] # restrict to my current public ip #TEST #TODO

  control_plane_subnet_ids = data.aws_subnets.private.ids

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = [] # empty to force each nodegroup to configure it

  iam_role_use_name_prefix = true
  iam_role_name            = local.cluster_name

  node_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name
  }

  iam_role_additional_policies = {
    "session_manager" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  addons = {
    coredns = {
      before_compute = true
    }
    kube-proxy = {
      before_compute = true
      most_recent = true
    }
    vpc-cni = {
      before_compute = true
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

  eks_managed_node_groups = {
    infra = {
      create = true
      partition = ""
      min_size     = 1
      max_size     = 1
      desired_size = 1

      disk_size = 20
      
      ami_type = "AL2023_x86_64_STANDARD"
      subnet_ids = [data.aws_subnet.us-east-1d.id]

      instance_types = ["t3a.medium"]
      capacity_type  = "ON_DEMAND"


      enable_efa_support = false
      enable_efa_only = false # Elastic Fabric Adapter (EFA) is a network interface for Amazon EC2 instances that enables customers to run applications requiring high levels of inter-node communications at scale on AWS. Its custom-built operating system (OS) bypass hardware interface enhances the performance of inter-instance communications, which is critical to scaling these applications. 

      labels = {
        role = "infra"
      }

      network_interfaces = [
        {
          associate_public_ip_address = false # by default, we disable public IPs
        }
      ]

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
  encryption_config       = null

  create_cloudwatch_log_group = false # disable cloudwatch logging
  enabled_log_types   = []    # disable cloudwatch logging

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
}
