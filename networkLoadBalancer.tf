resource "exoscale_nlb" "website" {
  name = "joe_nlb"
  description = "This is the Network Load Balancer for magnificent computing"
  zone = var.zone
}

resource "exoscale_nlb_service" "http" {
  zone = exoscale_nlb.website.zone
  name = "joe_http"
  description = "Website over HTTP"
  nlb_id = exoscale_nlb.website.id
  instance_pool_id = exoscale_instance_pool.joes_service.id
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
