data "aws_eks_cluster" "eks" {
  name = "eks-${var.env}"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = data.aws_eks_cluster.eks.name
}

data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.eks.version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

data "aws_iam_role" "node_iam_role" {
  name = var.node_iam_role_name
}
