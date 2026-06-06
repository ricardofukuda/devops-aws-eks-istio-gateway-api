include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../../eks-cluster"]
}

terraform {
  source = "${get_terragrunt_dir()}/../../../..//infra/services/infra/k8s-gateway-api-crd"
}