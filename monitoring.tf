resource "exoscale_compute" "monitoring" {
  zone = var.zone
  display_name = "Monitoring"
  template_id = data.exoscale_compute_template.ubuntu.id
  size = "small"
  disk_size = 10
  state = "Running"

  key_pair = exoscale_ssh_keypair.joe.name
  security_group_ids = [exoscale_security_group.super_secure.id]


  user_data = templatefile("./userdata/monitorService.sh", {
    env_exoscale_key = var.exoscale_key,
    env_exoscale_secret = var.exoscale_secret,
    env_exoscale_zone_id = var.zone_id,
    env_exoscale_instancepool_id = exoscale_instance_pool.instancepool.id,
    env_node_exporter_port = var.node_exporter_port,
    env_autoscaler_listen_port = var.autoscaler_listen_port
  })
}
