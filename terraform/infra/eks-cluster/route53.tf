resource "aws_route53_zone" "private" {
  name = var.route53_domain
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  force_destroy = true
}
