resource "kubernetes_secret" "admin_credentials" {
  metadata {
    name      = "admin-credentials"
    namespace = local.namespace
  }

  data = {
    "admin-user" = "admin"  # TEST ONLY
    "admin-password" = "admin"  # TEST ONLY
  }

  type = "Opaque"
}