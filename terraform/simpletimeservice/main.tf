
# Kubernetes Deployment
# Deploys the SimpleTimeService application to EKS
resource "kubernetes_deployment_v1" "simple_time_service" {
  metadata {
    name = var.k8s-label

    labels = {
      app = var.k8s-label
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = var.k8s-label
      }
    }

    template {
      metadata {
        labels = {
          app = var.k8s-label
        }
      }

      spec {
        container {
          name  = "app"

          # Docker image published to public registry
          image = var.eks-image

          # Application listens on port 8080
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

# Kubernetes Service
# Exposes the application externally using an AWS Load Balancer
resource "kubernetes_service_v1" "simple_time_service" {
  metadata {
    name = var.k8s-label

    # Forces Classic Load Balancer to operate in HTTP mode
    # Required to inject X-Forwarded-For headers
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
    }
  }

  spec {
    # Match pods created by the deployment
    selector = {
      app = var.k8s-label
    }

    # Create an AWS-managed Load Balancer
    type = "LoadBalancer"

    # Preserve the real client IP by disabling SNAT
    external_traffic_policy = "Local"

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
  }
}
