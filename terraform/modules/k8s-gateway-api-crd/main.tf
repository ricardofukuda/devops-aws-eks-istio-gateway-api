# INSTALL KUBERNETES GATEWAY API CRD USING OFFICIAL MANIFEST

data "http" "manifets_download" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml"
}

locals {
  manifest_raw = [
    for manifest in provider::kubernetes::manifest_decode_multi(data.http.manifets_download.response_body) :
    { for key, value in manifest : key => value if key != "status" } # remove 'status' line because kubernetes_manifest doesnt support
  ]
}

resource "kubernetes_manifest" "gateway_api_manifests" {
  count = length(local.manifest_raw)
  manifest = local.manifest_raw[count.index]
}