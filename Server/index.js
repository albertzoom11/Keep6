const express = require('express');
const bcrypt = require('bcryptjs');
var admin = require('firebase-admin');
var serviceAccount = require("./keep6-750b8-firebase-adminsdk-atacj-e1b2a9d424.json");
var path = require('path');
var bodyParser = require('body-parser');
const http = require('http');
const WebSocket = require('ws');
const PORT = process.env.PORT || 80;



let covid;
const server = http.createServer(function (req, res) {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.write('');
  res.end();
});

var app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://keep6-750b8.firebaseio.com/"
});

var database = admin.database();

const wss = new WebSocket.Server({ server });
var distance;
var covidKey;
var forceWhitelist = false;
var covidColor = "green";
server.listen(1319);

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    console.log('received: %s', message);
  });
});

express()
  .use(express.static(path.join(__dirname, 'public')))
  .use(bodyParser.urlencoded({ extended: false }))
  .set('views', path.join(__dirname, 'views'))
  .set('view engine', 'ejs')
  .post('/googleSignIn', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let profile = req.headers;
    let email = profile.email;
    let name = profile.name;
    console.log(name);
    let myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (!myVal) {
      database.ref("users").push({
        email: email,
        password: "",
        name: name
      });
    }
    myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    for (key in myVal) {
      userKey = key;
    }
    let returnVal = {
      userkey: userKey,
      name: name,
      email: email
    }
    res.send(returnVal);
  })
  .get('/getColor', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    res.send({
      corona: covidColor
    });
  })
  .get('/hardwareConnect', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let id = req.query.id;
    let rfid = req.query.rfid;
    let color = "";
    let myVal = await database.ref("users").orderByChild('arduino').equalTo(id).once("value");
    let whitelist;
    myVal = myVal.val();
    let userID;
    for (key in myVal) {
      userID = key;
      whitelist = myVal[key].whitelist;
    }
    if (whitelist === null || whitelist === undefined || whitelist.length == 0) {
      forceWhitelist = false;
    } else {
      let arr = whitelist.split(", ");
      if (arr.includes(rfid)) {
        forceWhitelist = true;
      } else {
        forceWhitelist = false;
      }
    }
    let myVal2 = await database.ref("users").orderByChild('rfid').equalTo(rfid).once("value");
    myVal2 = myVal2.val();
    for (key in myVal2) {
      covid = myVal2[key].corona;
    }
    if (forceWhitelist || distance > 6) {
      color = 'green'
    } else if (distance <= 6 && covid === "true") {
      color = 'red'
    } else {
      color = 'yellow'
    }
    covidKey = userID;
    covidColor = color;
    wss.clients.forEach(function each(client) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(`${covidKey} ${covidColor} ${distance}`);
      }
    });
    let returnVal = {
      corona: color
    }
    res.send(returnVal);
  })
  .post('/signIn', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let info = req.headers;
    let email = info.email;
    let password = info.password;
    let returnVal;
    let myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (!myVal) {
      returnVal = {
        data: "Incorrect email address."
      }
    } else {
      let inputPassword = password;
      let userPassword;
      for (key in myVal) {
        userPassword = myVal[key].password;
      }
      if (bcrypt.compareSync(inputPassword, userPassword)) {
        for (key in myVal) {
          returnVal = {
            data: key,
            name: myVal[key].name,
            email: email
          }
        }
      } else {
        returnVal = {
          data: "Incorrect Password"
        }
      }
    }
    res.send(returnVal);
  })
  .post('/signUp', async function (req, res) {
    let info = req.headers;
    let email = info.email;
    let firstName = info.firstname;
    let lastName = info.lastname;
    let password = info.password;
    let passwordConfirm = info.passwordconfirm;
    let returnVal;
    if (!email) {
      returnVal = {
        data: 'Please enter an email address.'
      };
      res.send(returnVal);
      return;
    }
    let myVal = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal = myVal.val();
    if (myVal) {
      returnVal = {
        data: 'Email already exists.'
      };
    } else if (firstName.length == 0 || lastName.length == 0) {
      returnVal = {
        data: 'Invalid Name'
      };
    } else if (!(/^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(firstName) && /^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(lastName))) {
      returnVal = {
        data: 'Invalid Name'
      };
    } else if (!(/(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/
      .test(email))) {
      returnVal = {
        data: 'Invalid email address.'
      };
    } else if (password.length < 6) {
      returnVal = {
        data: 'Your password needs to be at least 6 characters.'
      };
    } else if (password != passwordConfirm) {
      returnVal = {
        data: 'Your passwords don\'t match.'
      };
    } else {
      const value = {
        email: email,
        password: hash(password),
        name: `${firstName} ${lastName}`
      }
      database.ref("users").push(value);
      returnVal = {
        data: key,
        name: `${firstName} ${lastName}`,
        email: email
      };
    }
    res.send(returnVal);
  })
  .post('/setupDevices', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let arduino = req.headers.arduino;
    let rfid = req.headers.rfid;
    let userid = req.headers.userid;
    let corona = req.headers.corona;
    let returnVal;
    if (!arduino || arduino == "") {
      returnVal = {
        data: "Please enter a reader access code."
      }
    } else if (!rfid || rfid == "") {
      returnVal = {
        data: "Please enter an RFID access code."
      }
    } else {
      database.ref(`users/${userid}/rfid`).set(rfid);
      database.ref(`users/${userid}/arduino`).set(arduino);
      database.ref(`users/${userid}/corona`).set(corona);
      returnVal = {
        data: "Success"
      }
    }
    res.send(returnVal);
  })
  .post('/changeDevices', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let arduino = req.headers.arduino;
    let rfid = req.headers.rfid;
    let userid = req.headers.userid;
    let returnVal;
    if (!arduino || arduino == "") {
      returnVal = {
        data: "Please enter a reader access code."
      }
    } else if (!rfid || rfid == "") {
      returnVal = {
        data: "Please enter an RFID access code."
      }
    } else {
      database.ref(`users/${userid}/rfid`).set(rfid);
      database.ref(`users/${userid}/arduino`).set(arduino);
      returnVal = {
        data: "Success"
      }
    }
    res.send(returnVal);
  })
  .post('/changeStatus', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let arduino = req.headers.arduino;
    let userid = req.headers.userid;
    let corona = req.headers.corona;
    let returnVal;
    database.ref(`users/${userid}/corona`).set(corona);
    returnVal = {
      data: "Success"
    }
    res.send(returnVal);
  })
  .post('/updateDistance', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let distance1 = req.headers.distance;
    distance = distance1;
    if (forceWhitelist || distance > 6) {
      covidColor = 'green'
    } else if (distance <= 6 && covid === "true") {
      covidColor = 'red'
    } else {
      covidColor = 'yellow'
    }
    wss.clients.forEach(function each(client) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(`${covidKey} ${covidColor} ${distance}`);
      }
    });
    res.send({
      data: "received",
      distance: distance1
    })
  })
  .post('/distance', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    res.send(distance)
  })
  .post('/removeWhitelist', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let userid = req.headers.userid;
    let email = req.headers.email;
    let returnVal;
    let myVal = await database.ref(`users/${userid}/whitelist`).once("value");
    myVal = myVal.val();
    let myVal2 = await database.ref(`users`).orderByChild('email').equalTo(email).once("value");
    myVal2 = myVal2.val();
    let rfid;
    for (key in myVal2) {
      rfid = myVal2[key].rfid;
    }
    if (myVal === null || !myVal.split(", ").includes(rfid)) {
      returnVal = {
        data: "Failure"
      }
    } else if (!myVal.includes(", ")) {
      if (myVal === rfid) {
        database.ref(`users/${userid}/whitelist`).set("");
        returnVal = {
          data: "Success"
        }
      }
    } else {
      let arr = myVal.split(", ");
      arr = arr.filter((val) => { return val != rfid });
      var finalVal = "";
      for (var i = 0; i < arr.length; i++) {
        finalVal += arr[i]
        if (i != arr.length - 1) {
          finalVal += ", ";
        }
      }
      database.ref(`users/${userid}/whitelist`).set(finalVal);
      console.log(finalVal);
      returnVal = {
        data: "Success"
      }
    }
    res.send(returnVal);
  })
  .post('/addWhitelist', async function (req, res) {
    res.setHeader('Access-Control-Allow-Origin', 'https://keep6.macrotechsolutions.us');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    let userid = req.headers.userid;
    let email = req.headers.email;
    let returnVal;
    let myVal = await database.ref(`users/${userid}/whitelist`).once("value");
    myVal = myVal.val();
    let myVal3 = await database.ref(`users/${userid}/email`).once("value");
    myVal3 = myVal3.val();
    let myVal2 = await database.ref("users").orderByChild('email').equalTo(email).once("value");
    myVal2 = myVal2.val();
    let rfid;
    for (key in myVal2) {
      rfid = myVal2[key].rfid;
    }
    if (myVal2 && myVal2 != myVal3 && !myVal.includes(rfid)) {
      for (key in myVal2) {
        if (!myVal || myVal == "") {
          database.ref(`users/${userid}/whitelist`).set(myVal2[key].rfid);
        } else {
          database.ref(`users/${userid}/whitelist`).set(`${myVal}, ${myVal2[key].rfid}`);
        }
      }
      returnVal = {
        data: "Success"
      }
    } else {
      returnVal = {
        data: "Failure"
      }
    }
    res.send(returnVal);
  })
  .listen(PORT, () => console.log(`Listening on ${PORT}`));

function hash(value) {
  let salt = bcrypt.genSaltSync(10);
  let hashVal = bcrypt.hashSync(value, salt);
  return hashVal;
}

function parseEnvList(env) {
  if (!env) {
    return [];
  }
  return env.split(',');
}

var originBlacklist = parseEnvList(process.env.CORSANYWHERE_BLACKLIST);
var originWhitelist = parseEnvList(process.env.CORSANYWHERE_WHITELIST);

// Set up rate-limiting to avoid abuse of the public CORS Anywhere server.
var checkRateLimit = require('./lib/rate-limit')(process.env.CORSANYWHERE_RATELIMIT);

var cors_proxy = require('./lib/cors-anywhere');
cors_proxy.createServer({
  originBlacklist: originBlacklist,
  originWhitelist: originWhitelist,
  requireHeader: ['origin', 'x-requested-with'],
  checkRateLimit: checkRateLimit,
  removeHeaders: [
    'cookie',
    'cookie2',
    // Strip Heroku-specific headers
    'x-heroku-queue-wait-time',
    'x-heroku-queue-depth',
    'x-heroku-dynos-in-use',
    'x-request-start',
  ],
  redirectSameOrigin: true,
  httpProxyOptions: {
    // Do not add X-Forwarded-For, etc. headers, because Heroku already adds it.
    xfwd: false,
  },
})
  .listen(4911, () => console.log(`Listening on ${4911}`))