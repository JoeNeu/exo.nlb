resource "exoscale_security_group" "super_secure" {
  name = "jn_sec"
  description = "Security Group managed by Joe's Terraform"
}

resource "exoscale_security_group_rules" "internal" {
  security_group_id = exoscale_security_group.super_secure.id

  ingress {
    protocol  = "TCP"
    ports     = ["3000", "9100"]
    user_security_group_list = [exoscale_security_group.super_secure.name]
  }
}

resource "exoscale_security_group_rules" "open" {
  security_group_id = exoscale_security_group.super_secure.id

  ingress {
    protocol  = "TCP"
    ports     = ["22", "8080", "9090"]
    cidr_list = ["0.0.0.0/0"]
  }
}
