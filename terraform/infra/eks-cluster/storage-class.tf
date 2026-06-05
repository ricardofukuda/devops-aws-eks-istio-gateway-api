resource "kubernetes_storage_class_v1" "ebs_csi_gp3" {
  metadata {
    name = "gp3"
  }
  storage_provisioner     = "ebs.csi.aws.com"
  reclaim_policy          = "Delete"
  allow_volume_expansion  = true
  parameters = {
    type = "gp3"
  }
  volume_binding_mode = "WaitForFirstConsumer"
  depends_on = [ module.eks, module.ebs_csi_role ]
}
