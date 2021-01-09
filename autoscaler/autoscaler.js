const http = require('http');

const secretKey = 		process.env.EXOSCALE_SECRET;
const apiKey = 			process.env.EXOSCALE_KEY;
const instancepoolId = 	process.env.EXOSCALE_INSTANCEPOOL_ID;
const zoneID = 			process.env.EXOSCALE_ZONE_ID;
const port =            8090;
const hostname =        '0.0.0.0';
const clientUrl = 		"https://api.exoscale.ch/compute";
const maxSize =         3;
const minSize =         1;


async function getCountOfVirtualMachinesFromInstancePool() {
    return new Promise(async (resolve, reject) => {
        await initCloudstack().exec('getInstancePool', {id: instancepoolId, zoneid: zoneID}, function(error, response) {
            if (error) {
                console.log("ERROR: Failed fetching from the Exoscale API.");
                reject(error);
            } else {
                if(!isEmpty(response) && response.count === 1){
                    resolve(response.instancepool[0].size);
                }
            }
        });
    })
}

function scaleInstancePool(newSize) {
    initCloudstack().exec('scaleInstancePool', {id: instancepoolId, zoneid: zoneID, size: newSize}, function(error, response) {
        if (error) {
            console.log("ERROR: Failed fetching from the Exoscale API.");
            return;
        }
        if(!isEmpty(response) && response.success === false){
            console.log("ERROR: Failed fetching from the Exoscale API.");
        }
    });
}

function initCloudstack() {
    return new (require('./cloudstack'))({
        apiUri: clientUrl,
        apiKey: apiKey,
        apiSecret: secretKey
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

const server = http.createServer(async (request, response) => {

    request.on('error', (err) => {
        console.error("Error: " + err);
        response.statusCode = 403;
        response.end();
    });
    if (request.method === 'POST' && (request.url === '/up' || request.url === '/down' || request.url === '/test')) {
        console.log("received POST request: " + request.url);
        if(request.url === '/test') {
            response.statusCode = 200;
            response.end();
        }
        const instanceCount = await getCountOfVirtualMachinesFromInstancePool();
        console.log("Instancepool size: " + instanceCount);
        if (typeof instanceCount === 'undefined' || !instanceCount || instanceCount === 0) {
            response.statusCode = 404;
            response.end();
        }
        else if(request.url === '/up') {
            if (instanceCount < maxSize) {
                scaleInstancePool(instanceCount +1);
                console.log('+++scale up:   New size: ' + (instanceCount +1));
            }
        }
        else if(request.url === '/down') {
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
    server.listen(port, hostname, () => {
        console.log(`Server running at http://${hostname}:${port}/`);
    });
} else {
    console.log("ERROR: You must provide these envs: EXOSCALE_SECRET, EXOSCALE_KEY, EXOSCALE_ZONE_ID");
}

process.on('SIGINT', function () {
    console.log('SIGINT received...');
    process.exit(0);
});
process.on('SIGTERM', function () {
    console.log('SIGTERM received...');
    process.exit(0);
});
