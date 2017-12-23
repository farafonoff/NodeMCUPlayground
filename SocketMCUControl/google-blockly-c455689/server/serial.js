const SerialPort = require('serialport');

let serialPorts = {};

let baud = 115200;

module.exports.getDevices = function() {
    return SerialPort.list().then((list) => {
        return list.map(dev => {
            return {
                provider: 'serial',
                id: dev.comName,
                description: dev.manufacturer
            }
        })
    });
}

module.exports.log = function(port) {
    return getPort(port);
}

function getPort(comName) {
    if (!serialPorts[comName]) {
        serialPorts[comName] = new SerialPort(comName, {
            baudRate: baud
          });
    }
    return serialPorts[comName];
}
