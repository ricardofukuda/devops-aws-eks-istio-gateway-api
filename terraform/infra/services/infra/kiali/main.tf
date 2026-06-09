resource "kubernetes_namespace" "kiali" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "kiali" {
  name             = "kiali"
  create_namespace = true

  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = local.namespace
  version    = "2.27.0"

  wait = true

  values = [data.template_file.values.rendered]

  depends_on = [ kubernetes_namespace.kiali ]
}

resource "kubernetes_manifest" "route" {
  manifest = yamldecode(<<-EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: kiali
  namespace: ${local.namespace}
spec:
  hostnames:
    - kiali.${var.route53_domain}
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: gateway-public
      namespace: istio-ingress
  rules:
    - backendRefs:
        - group: ''
          kind: Service
          name: kiali
          port: 20001
          weight: 1
      matches:
        - path:
            type: PathPrefix
            value: /
EOF
  )

  depends_on = [ kubernetes_namespace.kiali ]
}