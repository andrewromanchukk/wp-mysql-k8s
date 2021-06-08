resource "kubernetes_service" "kibana-svc" {
  metadata {
    name = "kibana"
    namespace = "kube-logging"
    labels = {
        app = "kibana"
    }
  }
  spec {
    port{
        port = 5601
    }
    selector = {
        app = "kibana"
    }
  }
  depends_on = [
    kubernetes_namespace.kube-logging-ns,
    kubernetes_service.els-svc,
    kubernetes_stateful_set.els
  ]
}

resource "kubernetes_deployment" "kibana-deployment" {
  metadata {
    name = "kibana"
    namespace = "kube-logging"
    labels = {
      "app" = "kibana"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
          app = "kibana"
      }
    }
    template {
      metadata {
          labels = {
              app = "kibana"
          }
      }
      spec {
          container {
              name = "kibana"
              image = "docker.elastic.co/kibana/kibana:7.13.1"
              resources {
                limits {
                    cpu = "1000m"
                }
                requests {
                    cpu = "100m"
                }
              }
              env {
                name = "ELASTICSEARCH_URL"
                value = "http://elasticsearch:9200"
              }
              port {
                container_port = 5601
              }
          }
      }
    }
  }
    depends_on = [
    kubernetes_namespace.kube-logging-ns,
    kubernetes_service.els-svc,
    kubernetes_stateful_set.els
  ]
}