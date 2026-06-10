# DEPLOY ISTIO GATEWAY MANIFEST

data "template_file" "test" {
  template = file("${path.module}/manifests/test.yaml")
  vars = {
    route53_domain = var.route53_domain
    lb_source_range = "${chomp(data.http.icanhazip.response_body)}/32" # my ip
    certificate_arn = data.aws_acm_certificate.certificate.arn
  }
}

locals {
  test_manifest_raw = provider::kubernetes::manifest_decode_multi(data.template_file.test.rendered)
}

resource "kubernetes_manifest" "test" {
  count = length(local.test_manifest_raw)
  manifest = local.test_manifest_raw[count.index]
}