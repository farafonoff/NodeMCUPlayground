let serial = require('./serial')

var express = require('express');
var bodyParser = require('body-parser');
var cors = require('cors')
var app = express();

app.use(bodyParser.json())
app.use(cors())

let providers = [serial]

app.get('/devices', function (req, res) {
    let promises = providers.map(prov => prov.getDevices())
    Promise.all(promises).then(responses => {
        return responses.reduce((result, list) => {
            return result.concat(list);
        }, [])
    }).then(combined => {
        res.send(JSON.stringify(combined, null, 2));
    });
});

app.post('/exec/serial/:id', function (req, res) {
    console.log(req.body)
    //serial.log(req.params.id).pipe(res);
});

app.get('/log/serial/:id', function (req, res) {
    serial.log(req.params.id).pipe(res);
});

app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});