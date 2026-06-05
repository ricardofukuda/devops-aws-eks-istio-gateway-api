include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../../eks-cluster"]
}