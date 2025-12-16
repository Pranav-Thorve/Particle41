output "load_balancer_dns" {
  value = kubernetes_service_v1.simple_time_service.status[0].load_balancer[0].ingress[0].hostname
}
