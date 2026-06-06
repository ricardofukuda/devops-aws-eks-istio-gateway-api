include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../karpenter-manifests", "../k8s-gateway-api-crd"]
}

#terraform {
#  source = "${get_terragrunt_dir()}/../../../..//infra/services/infra/istio"
#}