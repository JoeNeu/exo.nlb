require("request");
const util = require('util');
const fs = require('fs');

var secretKey = "WZiVaq0_7X7IWrABwhsnjtq95biBtCFZmGZuj3gjWj0";// process.env.api_secret;
var apiKey = "EXOfd8e873734f8157f27de47ee";// process.env.api_key;
var clientUrl = "https://api.exoscale.ch/compute";
const interval = 30 * 1000; // 30sec

console.log("NodeExporter Starting");


if(	typeof secretKey !== 'undefined' && secretKey && typeof apiKey !== 'undefined' && apiKey) {
	console.log("ApiKey and Secret provided")

	setInterval(function() {
		console.log("Start fetching instances");
		var cloudstack = new (require('./lib/cloudstack'))({
			apiUri: clientUrl,
			apiKey: apiKey,
			apiSecret: secretKey
		});
		
		cloudstack.exec('listVirtualMachines', {}, function(error, result) {
			if (error) {
				console.log("Something went wrong while fetching the exoscale api");
			} else {
				console.log(util.inspect(result, {showHidden: false, depth: null}))

				fs.writeFile('user.json', JSON.stringify(result), (err) => {
					if (err) {
						throw err;
					}
					console.log("JSON data is saved.");
				});
			}
		});
	}, interval);

} else {
	console.log("ApiKey or Secret NOT provided");
}