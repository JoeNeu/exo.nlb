resource "exoscale_security_group" "joes_sec" {
  name = "joe_sec"
  description = "Security Group for Joe's Computing Cluster"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.joes_sec.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 80
  end_port = 80
}
