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
  scrape_interval: 15s
scrape_configs:
  - job_name: ’discovery’
    file_sd_configs:
      - files:
        - /srv/service-discovery/config.json
        refresh_interval: 5s
""" >> /etc/prometheus.yml

# Grafana datasource -> Prometheus
echo """
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    orgId: 1
    url: http://prometheus:9090
    version: 1
    editable: false
""" >> /etc/datasource.yaml

# Grafana notifier webhooks
echo """
notifiers:
  - name: scale up
    type: webhook
    uid: scale-up
    is_default: false
    send_reminder: true
    frequency: '5m'
    disable_resolve_message: true
    settings:
      autoResolve: true
      httpMethod: 'POST'
      severity: 'critical'
      uploadImage: false
      url: 'http://autoscaler:8090/up'
  - name: scale down
    type: webhook
    uid: scale-down
    is_default: false
    send_reminder: true
    frequency: '5m'
    disable_resolve_message: true
    settings:
      autoResolve: true
      httpMethod: 'POST'
      severity: 'critical'
      uploadImage: false
      url: 'http://autoscaler:8090/down'
""" >> /etc/notifiers.yaml

# Create dashboard configuration
echo """
apiVersion: 1
providers:
  - name: 'Home'
    orgId: 1
    folder: ''
    type: file
    updateIntervalSeconds: 10
    options:
      path: /etc/grafana/dashboards
""" >> /etc/dashboards.yaml

# Dashboard configuration
echo '{"annotations":{"list":[{"builtIn":1,"datasource":"-- Grafana --","enable":true,"hide":true,"iconColor":"rgba(0, 211, 255, 1)","name":"Annotations & Alerts","type":"dashboard"}]},"editable":true,"gnetId":null,"graphTooltip":0,"id":1,"links":[],"panels":[{"alert":{"alertRuleTags":{},"conditions":[{"evaluator":{"params":[0.8],"type":"gt"},"operator":{"type":"and"},"query":{"params":["A","1m","now"]},"reducer":{"params":[],"type":"avg"},"type":"query"}],"executionErrorState":"alerting","for":"1m","frequency":"1m","handler":1,"name":"High CPU alert","noDataState":"no_data","notifications":[{"uid":"scale-up"}]},"aliasColors":{},"bars":false,"dashLength":10,"dashes":false,"datasource":"Prometheus","fieldConfig":{"defaults":{"custom":{},"mappings":[],"thresholds":{"mode":"absolute","steps":[{"color":"green","value":null},{"color":"red","value":80}]},"unit":"percentunit"},"overrides":[]},"fill":1,"fillGradient":0,"gridPos":{"h":9,"w":12,"x":0,"y":0},"hiddenSeries":false,"id":2,"legend":{"avg":false,"current":false,"max":false,"min":false,"show":true,"total":false,"values":false},"lines":true,"linewidth":1,"nullPointMode":"null","options":{"alertThreshold":true},"percentage":false,"pluginVersion":"7.3.6","pointradius":2,"points":false,"renderer":"flot","seriesOverrides":[],"spaceLength":10,"stack":false,"steppedLine":false,"targets":[{"expr":"avg( sum by (instance) (rate(node_cpu_seconds_total{mode!=\"idle\"}[1m])) /   sum by (instance) (rate(node_cpu_seconds_total[1m])))","instant":false,"interval":"","legendFormat":"","refId":"A"}],"thresholds":[{"colorMode":"critical","fill":true,"line":true,"op":"gt","value":0.8}],"timeFrom":null,"timeRegions":[],"timeShift":null,"title":"High CPU","tooltip":{"shared":true,"sort":0,"value_type":"individual"},"type":"graph","xaxis":{"buckets":null,"mode":"time","name":null,"show":true,"values":[]},"yaxes":[{"format":"percentunit","label":null,"logBase":1,"max":"1","min":"0","show":true},{"format":"short","label":null,"logBase":1,"max":"1","min":"0","show":true}],"yaxis":{"align":false,"alignLevel":null}},{"alert":{"alertRuleTags":{},"conditions":[{"evaluator":{"params":[0.2],"type":"lt"},"operator":{"type":"and"},"query":{"params":["A","1m","now"]},"reducer":{"params":[],"type":"avg"},"type":"query"}],"executionErrorState":"alerting","for":"1m","frequency":"1m","handler":1,"name":"Low CPU alert","noDataState":"no_data","notifications":[{"uid":"scale-down"}]},"aliasColors":{},"bars":false,"dashLength":10,"dashes":false,"datasource":"Prometheus","fieldConfig":{"defaults":{"custom":{},"mappings":[],"thresholds":{"mode":"absolute","steps":[{"color":"green","value":null},{"color":"red","value":80}]},"unit":"percentunit"},"overrides":[]},"fill":1,"fillGradient":0,"gridPos":{"h":9,"w":12,"x":12,"y":0},"hiddenSeries":false,"id":3,"legend":{"avg":false,"current":false,"max":false,"min":false,"show":true,"total":false,"values":false},"lines":true,"linewidth":1,"nullPointMode":"null","options":{"alertThreshold":true},"percentage":false,"pluginVersion":"7.3.6","pointradius":2,"points":false,"renderer":"flot","seriesOverrides":[],"spaceLength":10,"stack":false,"steppedLine":false,"targets":[{"expr":"avg( sum by (instance) (rate(node_cpu_seconds_total{mode!=\"idle\"}[1m])) /   sum by (instance) (rate(node_cpu_seconds_total[1m])))","instant":false,"interval":"","legendFormat":"","refId":"A"}],"thresholds":[{"colorMode":"critical","fill":true,"line":true,"op":"lt","value":0.2}],"timeFrom":null,"timeRegions":[],"timeShift":null,"title":"Low CPU","tooltip":{"shared":true,"sort":0,"value_type":"individual"},"type":"graph","xaxis":{"buckets":null,"mode":"time","name":null,"show":true,"values":[]},"yaxes":[{"format":"percentunit","label":null,"logBase":1,"max":"1","min":"0","show":true},{"format":"short","label":null,"logBase":1,"max":"1","min":"0","show":true}],"yaxis":{"align":false,"alignLevel":null}}],"schemaVersion":26,"style":"dark","tags":[],"templating":{"list":[]},"time":{"from":"now-5m","to":"now"},"timepicker":{},"timezone":"","title":"autoscaler","uid":"Zt9HEuaGk","version":10}' >> /etc/dashboard.json

# Create docker network
docker network create monitoring

# Create shared docker-volume
docker volume create --name DiscoveryConfig

# Run Service Discovery
docker run -d \
  --name=serviceDiscovery \
  --restart=always \
  --net=monitoring \
  -v DiscoveryConfig:/srv/service-discovery/ \
  -e EXOSCALE_SECRET=${env_exoscale_secret} \
  -e EXOSCALE_KEY=${env_exoscale_key} \
  -e EXOSCALE_ZONE_ID=${env_exoscale_zone_id} \
  -e TARGET_PORT=${env_node_exporter_port} \
  joeneu/exo-service-discovery

# Run Prometheus
docker run -d \
  -p 9090:9090 \
  --name=prometheus \
  --net=monitoring \
  -v /etc/prometheus.yml:/etc/prometheus/prometheus.yml \
  --volumes-from serviceDiscovery:ro \
  prom/prometheus

# Run Autoscaler
docker run -d \
  --name=autoscaler \
  --restart=always \
  -p 8090:8090 \
  --net=monitoring \
  -e EXOSCALE_SECRET=${env_exoscale_secret} \
  -e EXOSCALE_KEY=${env_exoscale_key} \
  -e EXOSCALE_ZONE_ID=${env_exoscale_zone_id} \
  -e EXOSCALE_INSTANCEPOOL_ID=${env_exoscale_instancepool_id} \
  -e LISTEN_PORT=${env_autoscaler_listen_port} \
  joeneu/exo-autoscaler

# Run Grafana
docker run -d \
  -p 3000:3000 \
  --name=grafana \
  --restart=always \
  --net=monitoring \
  -v /etc/datasource.yaml:/etc/grafana/provisioning/datasources/datasource.yaml \
  -v /etc/notifiers.yaml:/etc/grafana/provisioning/notifiers/notifiers.yaml \
  -v /etc/dashboards.yaml:/etc/grafana/provisioning/dashboards/dashboards.yaml \
  -v /etc/dashboard.json:/etc/grafana/dashboards/dashboard.json \
  grafana/grafana
