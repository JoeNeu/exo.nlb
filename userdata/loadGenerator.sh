#!/bin/bash

# Abort if an error occurs
set -e
# Do not ask any questions and assume the defaults.
export DEBIAN_FRONTEND=noninteractive

# region Add Docker Repository
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

# Run the load generator
# Provided from Janos Pasztor
# https://github.com/janoszen
docker run -d \
  --restart=always \
  -p 8080:8080 \
  janoszen/http-load-generator:1.0.1

# Run the node exporter
docker run -d \
  -p 9100:9100 \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter \
  --path.rootfs=/host
