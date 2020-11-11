resource "exoscale_nlb" "network_load_balancer" {
  name = "jn_network_load_balancer"
  description = "Managed by Joe's Terraform"
  zone = var.zone
}

resource "exoscale_nlb_service" "healthchecker" {
  zone = exoscale_nlb.network_load_balancer.zone
  name = "jn_healthchecker"
  description = "Check Website over HTTP"
  nlb_id = exoscale_nlb.network_load_balancer.id
  instance_pool_id = exoscale_instance_pool.instancepool.id
  protocol = "tcp"
  port = 80
  target_port = 8080
  strategy = "round-robin"

  healthcheck {
    port = 8080
    mode = "http"
    uri = "/health"
    interval = 5
    timeout = 3
    retries = 1
  }
}
