# Exoscale Network Load Balancer

Terraform configuration that starts a network load balancer which manages an instancepool with n instances.
The n instances are monitored by an independent instance with [Prometheus](https://prometheus.io/) and the [Docker Service Discovery](https://hub.docker.com/repository/docker/joeneu/exo-service-discovery).

## Start

Environment Variables to start

                EXOSCALE_SECRET
                EXOSCALE_KEY
    (Optional)  EXOSCALE_ZONE_ID
    (Optional)  process.env.TARGET_PORT

Change the public key in the ssh.tf file to your own public key unless you want me to inspect your instances ;)

Start

    terraform apply
    
Destroy

    terraform destroy
    
## Finally

If you want more awesome cloud content, check out this dude [Janos Pasztor](https://github.com/janoszen).
