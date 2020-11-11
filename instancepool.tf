resource "exoscale_instance_pool" "instancepool" {
  zone = var.zone
  name = "jn_instancepool"
  description = "Managed by Joe's Terraform"
  template_id = data.exoscale_compute_template.ubuntu.id
  service_offering = "micro"
  size = 2
  disk_size = 10

  key_pair = exoscale_ssh_keypair.joe.name
  security_group_ids = [exoscale_security_group.super_secure.id]

  user_data = file("./userdata/loadGenerator.sh")
}
