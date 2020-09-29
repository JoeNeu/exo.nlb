data "exoscale_compute_template" "ubuntu" {
  zone = var.zone
  name = var.template
}

resource "exoscale_instance_pool" "instancepool" {
  zone = var.zone
  name = "jn_instancepool"
  template_id = data.exoscale_compute_template.ubuntu.id
  service_offering = "micro"
  size = 2
  disk_size = 10
  security_group_ids = [exoscale_security_group.super_secure.id]
  user_data = file("./Userdata/nginx.sh")
}
