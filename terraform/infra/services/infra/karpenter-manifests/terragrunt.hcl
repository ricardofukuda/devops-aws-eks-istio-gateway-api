include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "karpenter"{
  config_path = "../karpenter"

  mock_outputs = {
    node_iam_role_name = "mock-karpenter-output"
    service_account = "mock-karpenter-output"
  }
}

inputs = {
  node_iam_role_name       = dependency.karpenter.outputs.node_iam_role_name
  service_account       = dependency.karpenter.outputs.service_account
}