#!/bin/bash

# Abort if an error occurs
set -e
# Do not ask any questions and assume the defaults.
export DEBIAN_FRONTEND=noninteractive

# region add Docker Repository
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
# endregion

# Create config File for prometheus
echo """
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: ’discovery’
    file_sd_configs:
      - files:
        - /srv/service-discovery/config.json
        refresh_interval: 5s
""" >> /etc/prometheus.yml

# Create shared docker-volume
docker volume create --name DiscoveryConfig

# Run Service Discovery
docker run -d \
  --name=ServiceDiscovery \
  --restart=always \
  -v DiscoveryConfig:/srv/service-discovery/ \
  -e EXOSCALE_SECRET=${env_exoscale_secret} \
  -e EXOSCALE_KEY=${env_exoscale_key} \
  -e EXOSCALE_ZONE_ID=${env_exoscale_zone_id} \
  -e TARGET_PORT=${env_node_exporter_port} \
  joeneu/exo-service-discovery

# Run Prometheus
docker run -d \
  -p 9090:9090\
  -v /etc/prometheus.yml:/etc/prometheus/prometheus.yml \
  --volumes-from ServiceDiscovery:ro \
  prom/prometheus
