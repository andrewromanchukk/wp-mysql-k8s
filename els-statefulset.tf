resource "kubernetes_stateful_set" "els" {
  metadata {
    name = "es-cluster"
    namespace = "kube-logging"
  }
  spec {
    service_name = "elasticseach"
    replicas = 3

    selector {
      match_labels = {
          app = "elasticsearch"
      }
    }

    template {
      metadata {
          labels = {
              app = "elasticsearch"
          }
      }
      spec {
        container {
            name = "elasticsearch"
            image = "docker.elastic.co/elasticsearch/elasticsearch:7.13.1"
            resources {
                limits {
                    cpu = "1000m"
                }
                requests {
                cpu = "100m"
                }   
            }
            port {
                container_port = 9200
                name = "rest"
                protocol = "TCP"
            }
            port {
                container_port = 9300
                name = "inter-node"
                protocol = "TCP"
            }
            volume_mount {
              name = "data"
              mount_path = "/usr/share/elasticsearch/data"
            }
            env {
              name = "cluster.name"
              value = "k8s-logs"
            }
            env {
              name = "node.name"
              value_from {
                field_ref {
                    field_path = "metadata.name"
                }
              }
            }
            # env {
            #   name = "discovery.seed_hosts"
            #   value = [ "es-cluster-0.elasticsearch", "es-cluster-1.elasticsearch", "es-cluster-2.elasticsearch" ]
            # }
            env {
              name = "discovery.seed_hosts"
              value = "es-cluster-0.elasticsearch"
            }
            env {
              name = "discovery.seed_hosts"
              value = "es-cluster-1.elasticsearch"
            }
            env {
              name = "discovery.seed_hosts"
              value = "es-cluster-2.elasticsearch"
            }
            # env {
            #   name = "cluster.initial_master_nodes"
            #   values = [ "es-cluster-0", "es-cluster-1", "es-cluster-2" ]
            # }
            env {
              name = "cluster.initial_master_nodes"
              value = "es-cluster-0"
            }
            env {
              name = "cluster.initial_master_nodes"
              value = "es-cluster-1"
            }
            env {
              name = "cluster.initial_master_nodes"
              value = "es-cluster-2"
            }
            env {
              name = "ES_JAVA_OPTS"
              value = "-Xms512m -Xmx512m"
            }
        }
        init_container {
          name = "fix-permisions"
          image = "busybox:latest" 
          command = ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]
          security_context {
            privileged = true
          }
          volume_mount {
            name = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
        init_container {
          name = "increase-vm-max-map"
          image = "busybox:latest" 
          command = ["sysctl", "-w", "vm.max_map_count=262144"]
          security_context {
            privileged = true
          }
        #   volume_mount {
        #     name = "data"
        #     mount_path = "/usr/share/elasticsearch/data"
        #   }
        }
        init_container {
          name = "increase-fd-ulimit"
          image = "busybox:latest" 
          command = ["sh", "-c", "ulimit -n 65536"]
          security_context {
            privileged = true
          }
        #   volume_mount {
        #     name = "data"
        #     mount_path = "/usr/share/elasticsearch/data"
        #   }
        }
    }
  }
  volume_claim_template {
    metadata {
        name = "data"
        labels = {
            app = "elasticsearch"
        }
    }
    spec {
        access_modes = [ "ReadWriteOnce" ]
        resources {
            requests = {
                storage = "10Gi"
            }
        }
    }

  }
}
depends_on = [
  kubernetes_namespace.kube-logging-ns,
  kubernetes_service.els-svc
]
}