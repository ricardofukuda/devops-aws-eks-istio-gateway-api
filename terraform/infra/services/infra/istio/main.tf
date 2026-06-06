# INSTALL PROFILE=AMBIENT REFERENCE https://istio.io/latest/docs/ambient/install/helm/
# PRE-REQUISITES https://istio.io/latest/docs/ambient/install/platform-prerequisites/#amazon-elastic-kubernetes-service-eks
# Install or upgrade the Kubernetes Gateway API CRDs https://gateway-api.sigs.k8s.io/guides/getting-started/introduction/#installing-gateway-api
# https://aws.amazon.com/blogs/networking-and-content-delivery/aws-load-balancer-controller-adds-general-availability-support-for-kubernetes-gateway-api/

resource "terraform_data" "eks_pre_requisites" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name eks-${var.env} && kubectl set env daemonset aws-node -n kube-system POD_SECURITY_GROUP_ENFORCING_MODE=standard"
  }
}

# https://artifacthub.io/packages/helm/istio-official/base/1.30.1
resource "helm_release" "istio_base" {
  name       = "istio-base"
  create_namespace = true

  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  version    = var.istio_version

  values = [data.template_file.values_base.rendered]

  depends_on = [terraform_data.eks_pre_requisites]
}

# https://artifacthub.io/packages/helm/istio-official/istiod/1.30.1
resource "helm_release" "istiod" {
  name       = "istiod"
  create_namespace = true

  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = var.istio_version

  values = [data.template_file.values_istiod.rendered]

  depends_on = [ helm_release.istio_base ]
}

# https://artifacthub.io/packages/helm/istio-official/cni/1.30.1
resource "helm_release" "istio_cni" {
  name       = "istio-cni"
  create_namespace = true

  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = "istio-system"
  version    = var.istio_version

  values = [data.template_file.values_cni.rendered]

  depends_on = [ helm_release.istiod ]
}

# https://artifacthub.io/packages/helm/istio-official/ztunnel/1.30.1
resource "helm_release" "istio_ztunnel" {
  name       = "istio-ztunnel"
  create_namespace = true

  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "ztunnel"
  namespace  = "istio-system"
  version    = var.istio_version

  values = [data.template_file.values_ztunnel.rendered]

  depends_on = [ helm_release.istio_cni ]
}
