data "exoscale_compute_template" "ubuntu" {
  zone = var.zone
  name = var.template
}
