remote_state {
  backend = "s3"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    key = "${path_relative_to_include()}/terraform.tfstate"
    bucket = "tf-fukuda-devops-aws-eks-istio-gateway-api"
    region = "us-east-1"
    use_lockfile = true
  }
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "skip"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "Project"     = "${local.env_vars_project.locals.project_name}"
      "Environment" = "${local.env_vars.locals.env}"
      "ManagedBy"   = "Terraform"
    }
  }
}
EOF
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_vars_project = read_terragrunt_config("project.hcl")
  env_vars_global = read_terragrunt_config(find_in_parent_folders("global.hcl"))
}

inputs = merge(
  local.env_vars.locals,
  local.env_vars_project.locals,
  local.env_vars_global.locals,
)