# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v21.12.0/modules/karpenter/main.tf
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.12.0" # this version uses Pod identity Agent instead of IRSA

  cluster_name = data.aws_eks_cluster.eks.name

  create_iam_role                 = true
  create_pod_identity_association = true # use instead of IRSA
  service_account                 = var.service_account

  create_node_iam_role = true

  enable_spot_termination = true

  iam_role_use_name_prefix   = true
  iam_role_name              = data.aws_eks_cluster.eks.name
  iam_policy_use_name_prefix = true
  iam_policy_name            = data.aws_eks_cluster.eks.name


  iam_role_policies = {
    "session_manager" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  create_access_entry = true # must be true => grants permition to the node's iam role to access the k8s API. This config is an alternative to the aws_auth configmap configuration.
}

# https://github.com/aws/karpenter-provider-aws/blob/v1.8.3/charts/karpenter/values.yaml
resource "helm_release" "karpenter" {
  name             = "karpenter"
  create_namespace = true

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  namespace  = "kube-system"
  version    = "1.8.3" # 1.8.3 compatible with eks 1.34

  wait = true

  values = [data.template_file.values.rendered]

  depends_on = [module.karpenter]
}
