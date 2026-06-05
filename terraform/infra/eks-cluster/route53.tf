resource "aws_route53_zone" "private" {
  name = var.route53_domain
  vpc {
    vpc_id = data.aws_vpc.selected.id
  }
  force_destroy = true
}
