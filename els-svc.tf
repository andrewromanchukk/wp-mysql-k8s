resource "kubernetes_service" "els-svc" {
  metadata {
    name = "elasticsearch"
    namespace = "kube-logging"
    labels = {
        app = "elasticsearch"
    }
  }
  spec {
    selector = {
        app = "elasticsearch"
    }
    cluster_ip = "None"
    port {
      port = 9200
      name = "rest"
    }
    port {
      port = 9300
      name = "inter-node"
    }
  }
  depends_on = [
    kubernetes_namespace.kube-logging-ns,
    
  ]
}