data "aws_eks_cluster" "eks" {
  name = "eks-${var.env}"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = data.aws_eks_cluster.eks.name
}

data "template_file" "values" {
  template = file("config/values.yaml")
  vars = {
    CLUSTER_NAME      = data.aws_eks_cluster.eks.name
    service_account   = var.service_account
    interruptionQueue = module.karpenter.queue_name
    endpoint          = data.aws_eks_cluster.eks.endpoint
  }
}
