resource "exoscale_security_group" "super_secure" {
  name = "jn_sec"
  description = "Security Group for Joe's Computing Cluster"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.super_secure.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 80
  end_port = 80
}
