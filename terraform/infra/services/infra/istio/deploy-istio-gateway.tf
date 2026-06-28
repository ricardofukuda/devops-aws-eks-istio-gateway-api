# DEPLOY ISTIO GATEWAY MANIFEST
resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"
  }
}

data "template_file" "istio_gateway" {
  template = file("${path.module}/manifests/istio-gateway.yaml")
  vars = {
    route53_domain = var.route53_domain
    lb_source_range = "${chomp(data.http.icanhazip.response_body)}/32" # my ip
    certificate_arn = data.aws_acm_certificate.certificate.arn
  }
}

locals {
  istio_gateway_manifest_raw = provider::kubernetes::manifest_decode_multi(data.template_file.istio_gateway.rendered)
}

resource "kubernetes_manifest" "istio_gateway" {
  count = length(local.istio_gateway_manifest_raw)
  manifest = local.istio_gateway_manifest_raw[count.index]

  depends_on=[helm_release.istio_base, kubernetes_namespace.app, kubernetes_namespace.istio_ingress]

  field_manager {
    force_conflicts = true
  }
}