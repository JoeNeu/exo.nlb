# Service Discovery

Written with Node.js, with the help of [Chatham/node-cloudstack](https://github.com/Chatham/node-cloudstack) repository.

## Start

Needs 4 Environment Variables to start.

    EXOSCALE_SECRET
    EXOSCALE_KEY
    EXOSCALE_ZONE_ID
    TARGET_PORT

## Output

    FilePath: /srv/service-discovery/config.json

     [
        {
          "targets": [ "1.2.3.4:9100", "4.5.6.7:9100" ],
          "labels": {}
        }
     ]
