resource "kubernetes_namespace" "kube-logging-ns" {
  metadata {
    name = "kube-logging"
  }
  
}
