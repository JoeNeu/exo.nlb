resource "exoscale_nlb" "network_load_balancer" {
  name = "jn_network_load_balancer"
  description = "This is the Network Load Balancer for magnificent computing"
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
  target_port = 80
  strategy = "round-robin"

  healthcheck {
    port = 80
    mode = "http"
    uri = "/"
    interval = 5
    timeout = 3
    retries = 1
  }
}
