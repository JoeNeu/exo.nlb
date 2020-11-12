require("request");
const fs = require('fs');

const secretKey = 		process.env.EXOSCALE_SECRET;
const apiKey = 			process.env.EXOSCALE_KEY;
const zoneID = 			process.env.EXOSCALE_ZONE_ID;
const targetPort = 		process.env.TARGET_PORT;

const clientUrl = 		"https://api.exoscale.ch/compute";
const interval = 		10 * 1000; // Milliseconds
const filepath =		'../srv/service-discovery/config.json';

if	(	
		typeof secretKey		!== 'undefined' 	&& secretKey 		&&
		typeof apiKey			!== 'undefined' 	&& apiKey 			&&
		typeof zoneID 			!== 'undefined' 	&& zoneID			&&
		typeof targetPort 		!== 'undefined' 	&& targetPort
	) 
{
	console.log("Service-Discovery started...")
	setInterval(function() {
		console.log("Fetching Instancepool...");
		var cloudstack = new (require('./lib/cloudstack'))({
			apiUri: clientUrl,
			apiKey: apiKey,
			apiSecret: secretKey
		});
		var ipAddresses = [];

		cloudstack.exec('listInstancePools', {zoneid: zoneID}, function(error, response) {
			if (error) {
				console.log("ERROR: Failed fetching from the Exoscale API. Retry.");
			} else {
				if(!isEmpty(response)){
					response.instancepool.forEach(pool => {
						pool.virtualmachines.forEach(machine => {
							machine.nic.forEach(network => {
								ipAddresses.push(network.ipaddress + ':' + targetPort);
							});
						});
					});
				}
				var result = [{targets: ipAddresses, labels: {}}];
				console.log("Targets: " + ipAddresses);

				fs.writeFile(filepath, JSON.stringify(result), (err) => {
					if (err) {
						console.log("ERROR writing file.")
						throw err;
					}
					console.log("JSON saved to: " + filepath);
				});
			}
		});
	}, interval);
} else {
	console.log("ERROR: You must provide these envs: EXOSCALE_SECRET, EXOSCALE_KEY, EXOSCALE_ZONE_ID and TARGET_PORT");
}

function isEmpty(obj) {
	for(var prop in obj) {
		if(obj.hasOwnProperty(prop)) {
			return false;
		}
	}

	return JSON.stringify(obj) === JSON.stringify({});
}
