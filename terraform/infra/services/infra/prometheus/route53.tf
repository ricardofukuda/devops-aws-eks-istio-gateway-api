locals{
    route53_record = "prometheus"
}

data "kubernetes_service" "istio" {
  metadata {
    name      = "gateway-public-istio"
    namespace = "istio-ingress"
  }
}

data "aws_route53_zone" "primary" {
  name         = "${var.route53_domain}"
  private_zone = false
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${local.route53_record}"
  type    = "CNAME"
  ttl = 900

  records        = ["${data.kubernetes_service.istio.status[0].load_balancer[0].ingress[0].hostname}"]
}