resource "exoscale_compute" "monitoring" {
  zone         = var.zone
  display_name = "Monitoring"
  template_id  = data.exoscale_compute_template.ubuntu.id
  size         = "micro"
  disk_size    = 10
  state        = "Running"

  key_pair     = exoscale_ssh_keypair.joe.name
  security_group_ids = [exoscale_security_group.super_secure.id]


  user_data = <<EOF
#!/bin/bash

set -e

export EXOSCALE_KEY="${var.exoscale_key}"
export EXOSCALE_SECRET="${var.exoscale_secret}"
export EXOSCALE_REGION="${var.zone}"

export DEBIAN_FRONTEND=noninteractive

# Add Docker Repository
# https://docs.docker.com/engine/install/ubuntu/
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
# Install Docker
apt-get install -y docker-ce docker-ce-cli containerd.io

# Run Service Discovery

# Run Prometheus
docker run -d \
  -p 9090:9090\
  -v /etc/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /srv/service-discovery/:/srv/service-discovery/ \
  prom/prometheus
EOF
}
