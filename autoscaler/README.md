# Autoscaler

Written with Node.js, with the help of [Chatham/node-cloudstack](https://github.com/Chatham/node-cloudstack) repository.

## Start

Needs 4 Environment Variables to start.

    EXOSCALE_SECRET
    EXOSCALE_KEY
    EXOSCALE_ZONE_ID
    EXOSCALE_INSTANCEPOOL_ID

## Path

    {address}/up
        increase provided Instancepool +1
    {address}/down
        decrease provided Instancepool -1
