include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_terragrunt_dir()}/../..//infra/eks-cluster"
}


dependency "network"{
  config_path = "../network"
  mock_outputs = {}
}

