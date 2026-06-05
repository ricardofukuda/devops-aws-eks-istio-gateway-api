locals {
  node_class_manifests = fileset(path.root, "${path.module}/manifests/ec2nodeclass/*.yaml")
  node_pool_manifests  = fileset(path.root, "${path.module}/manifests/nodepool/*.yaml")
}

data "template_file" "node_class_manifests" {
  for_each = local.node_class_manifests

  template = file(each.value)

  vars = {
    CLUSTER_NAME       = data.aws_eks_cluster.eks.name
    eks_ami            = data.aws_ssm_parameter.eks_ami.value
    node_iam_role_name = var.node_iam_role_name
  }
}

data "template_file" "node_pool_manifests" {
  for_each = local.node_pool_manifests

  template = file(each.value)

  vars = {
    CLUSTER_NAME       = data.aws_eks_cluster.eks.name
    eks_ami            = data.aws_ssm_parameter.eks_ami.value
    node_iam_role_name = data.aws_iam_role.node_iam_role.name
  }
}

resource "kubernetes_manifest" "node_class_manifests" {
  for_each = data.template_file.node_class_manifests

  manifest = yamldecode(each.value.rendered)

}

resource "kubernetes_manifest" "node_pool_manifests" {
  for_each = data.template_file.node_pool_manifests

  manifest = yamldecode(each.value.rendered)

  depends_on = [kubernetes_manifest.node_class_manifests]
}
