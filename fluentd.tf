
resource "kubernetes_service_account" "fluentd-sa" {
  metadata {
    name = "fluentd"
    namespace = "kube-logging"
    labels = {
      "app" = "fluentd"
    }
  }
  depends_on = [
    kubernetes_namespace.kube-logging-ns,
    kubernetes_service.els-svc,
    kubernetes_stateful_set.els,
    kubernetes_service.kibana-svc,
    kubernetes_deployment.kibana-deployment
  ]
}

resource "kubernetes_cluster_role" "fluentd-cr" {
  metadata {
    name = "fluentd"
    labels = {
      app = "fluentd"
    }
  }
  rule {
    api_groups = [""]
    resources = ["pods", "namespaces"]
    verbs = [ "get", "list", "watch" ]
  }
  depends_on = [
    kubernetes_namespace.kube-logging-ns,
    kubernetes_service.els-svc,
    kubernetes_stateful_set.els,
    kubernetes_service.kibana-svc,
    kubernetes_deployment.kibana-deployment
  ]
}

resource "kubernetes_role_binding" "fluentd-crb" {
  metadata {
    name = "fluentd"
  }
  role_ref {
    kind = "ClusterRole"
    name = "fluentd"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind = "ServiceAccount"
    name = "fluentd"
    namespace = "kube-logging"
  }
  depends_on = [
    kubernetes_namespace.kube-logging-ns,
    kubernetes_service.els-svc,
    kubernetes_stateful_set.els,
    kubernetes_service.kibana-svc,
    kubernetes_deployment.kibana-deployment
  ]
}

resource "kubernetes_daemonset" "fluentd-daemonset" {
  metadata {
    name = "fluentd"
    namespace = "kube-logging"
    labels = {
      app = "fluentd"
    }
  }
  spec {
    selector {
      match_labels = {
        "app" = "fluentd"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "fluentd"
        }
      }
      spec {
        # service_account = "fluentd"
        service_account_name = "fluentd"
        toleration {
          key = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
        container {
          name = "fluentd"
          image = "fluent/fluentd-kubernetes-daemonset:v1.4.2-debian-elasticsearch-1.1"
          env {
            name = "FLUENT_ELASTICSEARCH_HOST"
            value = "elasticsearch.kube-logging.svc.cluster.local"
          }
          env {
            name = "FLUENT_ELASTICSEARCH_SCHEME"
            value = "http"
          }
          env {
            name = "FLUENT_ELASTICSEARCH_PORT"
            value = "9200"
          }
          env {
            name = "FLUENTD_SYSTEMD_CONF"
            value = "disable"
          }
          resources {
            limits {
              memory = "512Mi"
            }
            requests {
              cpu = "100m"
              memory = "200Mi"
            }
          }
          volume_mount {
            name = "varlog"
            mount_path = "/var/log"
          }
          volume_mount {
            name = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only = true
          }
        }
        termination_grace_period_seconds = 30
        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "varlibdockercontainers"
          host_path  {
            path = "/var/lib/docker/containers"
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_namespace.kube-logging-ns,
    kubernetes_service.els-svc,
    kubernetes_stateful_set.els,
    kubernetes_service.kibana-svc,
    kubernetes_deployment.kibana-deployment
  ]
}