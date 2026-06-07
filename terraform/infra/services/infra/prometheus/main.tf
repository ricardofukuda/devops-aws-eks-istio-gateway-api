
resource "helm_release" "prometheus_stack" {
  name             = "prometheus-stack"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "prometheus-stack"
  version    = "86.2.0"

  wait = true

  values = [data.template_file.values.rendered]
}
