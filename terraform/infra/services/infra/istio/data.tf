locals {
  allow_ips = [
    "${chomp(data.http.icanhazip.response_body)}/32" # my public IP
  ]
  github_webhook_ips = [for s in jsondecode(data.http.github-metadata.response_body).hooks : s if strcontains(s, "::") ==  false] # pull github webhook public ips
}

data "aws_eks_cluster" "eks" {
  name = "eks-${var.env}"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name =  data.aws_eks_cluster.eks.name
}

data "template_file" "values" {
  template = file("config/values.yml")
  vars = {
  }
}

data "template_file" "values_ingressgateway_public" {
  template = file("config/values_ingressgateway_public.yml")
  vars = {
    certificate_arn = data.aws_acm_certificate.certificate.arn
    #cidr_range = join(",", local.allow_ips, local.github_webhook_ips) # FOR LOCAL DEVELOPMENT ONLY
    cidr_range = join(",", local.allow_ips)
  }
}

data "template_file" "values_base" {
  template = file("config/values_base.yml")
  vars = {
  }
}

data "aws_acm_certificate" "certificate" {
  domain      = var.route53_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

data "http" "icanhazip" { # get my current public ip
   url = "http://icanhazip.com"
}

data "http" "github-metadata" { # get github metadatas
  url = "https://api.github.com/meta"

  request_headers = {
    Accept = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
  }
}
