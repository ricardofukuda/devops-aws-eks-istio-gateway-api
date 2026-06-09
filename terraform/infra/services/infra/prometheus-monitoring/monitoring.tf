# DEPLOY ISTIO GATEWAY MANIFEST

data "template_file" "istio_monitoring" {
  template = file("${path.module}/manifests/istio-monitoring.yaml")
  vars = {
    route53_domain = var.route53_domain
  }
}

locals {
  istio_monitoring_manifest_raw = provider::kubernetes::manifest_decode_multi(data.template_file.istio_monitoring.rendered)
}

resource "kubernetes_manifest" "istio_monitoring" {
  count = length(local.istio_monitoring_manifest_raw)
  manifest = local.istio_monitoring_manifest_raw[count.index]
}