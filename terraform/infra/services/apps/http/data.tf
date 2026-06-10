data "aws_eks_cluster" "eks" {
  name = "eks-${var.env}"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = data.aws_eks_cluster.eks.name
}

data "aws_acm_certificate" "certificate" {
  domain      = var.route53_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

data "http" "icanhazip" { # get my current public ip
   url = "http://icanhazip.com"
}
