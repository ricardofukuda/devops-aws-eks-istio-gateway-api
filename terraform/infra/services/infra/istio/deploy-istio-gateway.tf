# DEPLOY ISTIO GATEWAY MANIFEST

data "template_file" "istio_gateway" {
  template = file("${path.module}/manifests/istio-gateway.yaml")
  vars = {
    route53_domain = var.route53_domain
  }
}

locals {
  istio_gateway_manifest_raw = provider::kubernetes::manifest_decode_multi(data.template_file.istio_gateway.rendered)
}

resource "kubernetes_manifest" "istio_gateway" {
  count = length(local.istio_gateway_manifest_raw)
  manifest = local.istio_gateway_manifest_raw[count.index]

  depends_on=[helm_release.istio_base]
}