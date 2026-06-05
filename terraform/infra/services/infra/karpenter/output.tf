output "node_iam_role_name" {
  value = module.karpenter.node_iam_role_name
}

output "service_account" {
  value = var.service_account
}
