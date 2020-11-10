resource "exoscale_compute" "monitoring" {
  zone         = var.zone
  display_name = "Monitoring"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "micro"
  disk_size    = 10
  state        = "Running"

  key_pair     = exoscale_ssh_keypair.joe.name
  security_group_ids = [exoscale_security_group.super_secure.id]

  provisioner "remote-exec" {
    script = "./Userdata/installDocker.sh"
  }

  provisioner "file" {
    source = "./Userdata/prometheus.yml"
    destination = "/etc/prometheus.yml"
  }

  provisioner "file" {
    source = "./Userdata/instancepoolExplorer.sh"
    destination = "/srv/exoscale/instancepoolExplorer.sh"
  }

  #Set Environment Variable
  provisioner "file" {
    content = <<EOF
#!/bin/bash

set -e

export EXOSCALE_KEY="${var.exoscale_key}"
export EXOSCALE_SECRET="${var.exoscale_secret}"
export EXOSCALE_REGION="${var.zone}"

docker run -d \
  -p 9090:9090\
  -v /etc/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /srv/service-discovery/:/srv/service-discovery/ \
  prom/prometheus
EOF
    destination = "/srv/docker/start.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -x",
//      "sudo mkdir -p /srv/grafana",
//      "sudo chmod 0777 /srv/grafana",
      "sudo mkdir -p /srv/prometheus",
      "sudo chmod 0777 /srv/prometheus",
      "sudo chown -R root:root .",
      // shell script needs +x
      "sudo chmod +x /srv/docker/start.sh",
      "sudo chmod +x /srv/exoscale/instancepoolExplorer.sh",
      "sudo corntab -e "
      "sudo /srv/docker/start.sh"
    ]
  }
}
