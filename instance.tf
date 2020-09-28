data "exoscale_compute_template" "ubuntu" {
  zone = var.zone
  name = var.template
}

resource "exoscale_instance_pool" "joes_service" {
  zone = var.zone
  name = "joe_instancepool"
  template_id = data.exoscale_compute_template.ubuntu.id
  service_offering = "micro"
  size = 2
  disk_size = 10
  security_group_ids = [exoscale_security_group.joes_sec.id]
  user_data = file("userdata.sh")
}
