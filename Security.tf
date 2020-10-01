resource "exoscale_security_group" "super_secure" {
  name = "jn_sec"
  description = "Security Group for Joe's Computing Cluster"
}

resource "exoscale_security_group_rule" "loadGenerator" {
  security_group_id = exoscale_security_group.super_secure.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 8080
  end_port = 8080
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.super_secure.id
  type = "INGRESS"
  protocol = "tcp"
  cidr = "0.0.0.0/0"
  start_port = 22
  end_port = 22
}
