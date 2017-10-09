var WebSocketServer = require('websocket').server;
var http = require('http');
var randomstring = require("randomstring");

var server = http.createServer(function(request, response) {
    // process HTTP request. Since we're writing just WebSockets
    // server we don't have to implement anything.
});
// create the server
wsServer = new WebSocketServer({
    httpServer: server
});

let peers = [];

function broadcastMessage(response) {
    console.log(response);
    peers.forEach(peer => {
        if (peer.connection.connected) {
            peer.connection.sendUTF(response);
        }
    })
}

function sendAllContacts() {
    let contactsObj = peers.map((peer, index) => {
        return { name: peer.name, id: index };
    });
    let response = JSON.stringify({type: 'contactlist', payload: contactsObj});
    broadcastMessage(response);
}

function findContactByRequest(request) {
    return peers.find(peer => peer.key === request.key);
}

// WebSocket server
wsServer.on('request', function(request) {
    var connection = request.accept(null, request.origin);
    // This is the most important callback for us, we'll handle
    // all messages from users here.
    connection.on('message', function(message) {
      if (message.type === 'utf8') {
        let data = JSON.parse(message.utf8Data);
        let peer = findContactByRequest(request);
        switch (data.type) {
            case 'register': {
                if (peer) {
                    peer.name = data.name;
                } else {
                    peers.push({name: data.name, key: request.key, connection: connection});
                }
                sendAllContacts();
                break;
            }
            case 'message': {
                console.log(data);
                let id = peers.indexOf(peer);
                broadcastMessage(JSON.stringify(
                    {
                        type: 'message', 
                        payload: {
                            from: {
                                id: id, 
                                name: peer.name}, 
                            content: data.content
                        }
                    }));
                break;
            }
        }
      }
    });
    function delConnection(reason) {
        console.log('client disconnect '+ reason);
        let peerIdx = peers.findIndex(peer => peer.connection === connection);
        if (peerIdx>=0) {
          peers.splice(peerIdx, 1);
        }
        sendAllContacts();
    }
    connection.on('close', delConnection);
  });

  server.listen(1337, function() { });  
