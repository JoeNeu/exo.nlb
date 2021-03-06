﻿# Exoscale Network Load Balancer, Service Discovery with Monitoring and Autoscaler

Terraform configuration that starts a network load balancer which manages an instancepool with n instances for [Exoscale Cloud Hosting](https://www.exoscale.com/).
The n instances are monitored by an independent instance with [Prometheus](https://prometheus.io/) and the [Docker Service Discovery](https://hub.docker.com/repository/docker/joeneu/exo-service-discovery). [Grafana](https://grafana.com/) displayes the load of the VMs and scales up an instance if the workload is above 80% for 1m. It scales down if the workload is below 20% by sending a webhook to the [Docker Autoscaler](https://hub.docker.com/repository/docker/joeneu/exo-autoscaler).

## Start

Environment Variables to start

                EXOSCALE_SECRET
                EXOSCALE_KEY
    (Optional)  EXOSCALE_ZONE_ID
    (Optional)  TARGET_PORT

Change the public key in the ssh.tf file to your own public key unless you want me to inspect your instances ;)

Start

    terraform apply
    
Don't forget to configure the Security Groups for your needs in security.tf. Grafana(p:3000), Prometheus(p:9090) and Autoscaler(p:8090) are only internal but can be accessed with the "open" security group.
    
Destroy

    terraform destroy
    
## Finally

If you want more awesome cloud content, check out this dude [Janos Pasztor](https://github.com/janoszen).
