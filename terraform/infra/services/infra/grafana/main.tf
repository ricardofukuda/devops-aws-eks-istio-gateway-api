resource "kubernetes_namespace" "grafana" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "grafana" {
  name             = "grafana"
  create_namespace = true

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = local.namespace
  version    = "10.5.15"

  wait = true

  values = [data.template_file.values.rendered]

  depends_on = [ kubernetes_namespace.grafana ]
}
