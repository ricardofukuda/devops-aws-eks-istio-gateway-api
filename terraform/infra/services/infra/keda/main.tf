resource "kubernetes_namespace" "keda" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "keda" {
  name             = "keda"
  create_namespace = true

  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = local.namespace
  version    = "2.20.0"

  wait = true

  values = [data.template_file.values.rendered]

  depends_on = [ kubernetes_namespace.keda ]
}
