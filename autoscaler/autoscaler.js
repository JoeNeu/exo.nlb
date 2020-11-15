const http = require('http');

const secretKey = 		process.env.EXOSCALE_SECRET;
const apiKey = 			process.env.EXOSCALE_KEY;
const instancepoolId = 	process.env.EXOSCALE_INSTANCEPOOL_ID;
const zoneID = 			process.env.EXOSCALE_ZONE_ID;
const port =            8090;
const hostname =        '127.0.0.1';
const clientUrl = 		"https://api.exoscale.ch/compute";
const maxSize =         3;
const minSize =         1;


function getCountOfVirtualMachinesFromInstancePool() {
    cloudstack.exec('getInstancePool', {id: instancepoolId, zoneid: zoneID}, function(error, response) {
        if (error) {
            console.log("ERROR: Failed fetching from the Exoscale API.");
        } else {
            if(!isEmpty(response) && response.count === 1){
                return response.instancepool[0].size;
            }
            return 0;
        }
    });
}

function scaleInstancePool(newSize) {
    cloudstack.exec('scaleInstancePool', {id: instancepoolId, zoneid: zoneID, size: newSize}, function(error, response) {
        if (error) {
            console.log("ERROR: Failed fetching from the Exoscale API.");
            return;
        }
        if(!isEmpty(response) && response.success === false){
            console.log("ERROR: Failed fetching from the Exoscale API.");
        }
    });
}

function isEmpty(obj) {
    for(var prop in obj) {
        if(obj.hasOwnProperty(prop)) {
            return false;
        }
    }
    return JSON.stringify(obj) === JSON.stringify({});
}

const server = http.createServer((request, response) => {
    const { headers, method, url } = request;

    request.on('error', (err) => {
        console.error("Error: " + err);
        response.statusCode = 403;
        response.end();
    });
    if (request.method === 'POST' && (request.url === '/up' || request.url === '/down')) {
        var instanceCount = 3; getCountOfVirtualMachinesFromInstancePool();
        console.log("Instancepool size: " + instanceCount);
        if (typeof instanceCount === 'undefined' || !instanceCount || instanceCount === 0) {
            response.statusCode = 404;
            response.end();
        }
        if (request.url === '/up') {
            if (instanceCount < maxSize) {
                scaleInstancePool(instanceCount +1);
                console.log('+++scale up:   New size: ' + (instanceCount +1));
            }
        }
        if (request.url === '/down') {
            if (instanceCount > minSize) {
                scaleInstancePool(instanceCount -1);
                console.log('---scale down: New size: ' + (instanceCount -1));
            }
        }
        response.statusCode = 200;
        response.end();
    }
});

if	(
    typeof secretKey		!== 'undefined' 	&& secretKey 		&&
    typeof apiKey			!== 'undefined' 	&& apiKey 			&&
    typeof zoneID 			!== 'undefined' 	&& zoneID			&&
    typeof instancepoolId 	!== 'undefined' 	&& instancepoolId
) {
    const cloudstack = new (require('./lib/cloudstack'))({
        apiUri: clientUrl,
        apiKey: apiKey,
        apiSecret: secretKey
    });
    server.listen(port, hostname, () => {
        console.log(`Server running at http://${hostname}:${port}/`);
    });
} else {
    console.log("ERROR: You must provide these envs: EXOSCALE_SECRET, EXOSCALE_KEY, EXOSCALE_ZONE_ID");
}
