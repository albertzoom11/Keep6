import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

String url = "https://keep6.macrotechsolutions.us/terms.html";
String userID = "";
String rfidNum = "";
String arduinoNum = "";
String username = "";
String password = "";
String firstName = "";
String lastName = "";
String confirmPassword = "";
String coronaStatus = "true";
var userJSON;
var setupJSON;
String whitelistEmail = "";
var whitelist = <String>[];
var color = "green";
var distance = "0";

void main() {
  runApp(MyApp());
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keep6',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      routes: {
        "/": (_) => MyHomePage(title: 'Keep6'),
        "/landing": (_) => LandingPage(),
        "/settings": (_) => SettingsPage(),
        "/setup": (_) => SetupPage(),
        "/whitelist": (_) => WhitelistPage(),
        "/webview": (_) =>
            WebviewScaffold(
              url: url,
              appBar: AppBar(
                title: Text("Contact MacroTech"),
              ),
              withJavascript: true,
              withLocalStorage: true,
              withZoom: true,
            )
      },
    );
  }
}

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  initState() {
    super.initState();
    webView.close();
    controller.addListener(() {
      url = controller.text;
    });
    initStateFunction();
  }

  initStateFunction() async {
    var prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID');
    rfidNum = prefs.getString('rfid');
    arduinoNum = prefs.getString('arduino');
    print(userID);
    if (userID != "" &&
        rfidNum != "" &&
        arduinoNum != "" &&
        userID != null &&
        rfidNum != null &&
        arduinoNum != null) {
      userJSON = json.decode(prefs.getString('userJSON'));
      coronaStatus = prefs.getString('corona');
      whitelist = prefs.getStringList('whitelist');
      if(whitelist == null){
        whitelist = [];
      }
      Navigator.pushReplacementNamed(context, "/landing");
    } else if (userID != "" && userID != null) {
      Navigator.pushReplacementNamed(context, "/setup");
    }
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  final webView = FlutterWebviewPlugin();
  TextEditingController controller = TextEditingController(text: url);

  @override
  void dispose() {
    webView.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Login\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                            'Use this feature to log in to an existing shopper account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                          TextSpan(
                            text: '\nSign Up\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                            'Use this feature to create a new shopper account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
            ),
            ListTile(
              title: RaisedButton(
                color: HexColor("00b2d1"),
                onPressed: () {
                  dispose() {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeRight,
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    super.dispose();
                  }

                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new SignInPage()));
                },
                child: Text("Login"),
              ),
            ),
            ListTile(
                title: RaisedButton(
                    color: HexColor("ff5ded"),
                    onPressed: () {
                      dispose() {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                        super.dispose();
                      }

                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SignUpPage()));
                    },
                    child: Text("Sign Up"))),
            ListTile(
                title: RaisedButton(
                    color: HexColor("c6c6c8"),
                    onPressed: () async {
                      Navigator.of(context).pushNamed("/webview");
                    },
                    child: Text("Terms and Conditions"))),
          ],
        ),
      ),
    );
  }
}

class SetupPage extends StatefulWidget {
  SetupPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  Future<String> createAlertDialog(BuildContext context, String title,
      String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    String result = "";
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup Keep6"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Setup\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                            'This screen will allow you to enter the hardware information necessary to communicate with the app.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "RFID Access Code"),
                keyboardType: TextInputType.number,
                onChanged: (String str) {
                  setState(() {
                    rfidNum = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Reader Access Code"),
                keyboardType: TextInputType.number,
                onChanged: (String str) {
                  setState(() {
                    arduinoNum = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Row(
                children: <Widget>[
                  Text("Do you have COVID-19?"),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: DropdownButton(
                        items: [
                          DropdownMenuItem<String>(
                            value: "true",
                            child: Text(
                              "Yes",
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: "false",
                            child: Text(
                              "No",
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          setState(() {
                            coronaStatus = value;
                          });
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setString('coronaStatus', coronaStatus);
                        },
                        value: coronaStatus,
                        isExpanded: true,
                      ),
                    ),),
                ],
              ),
            ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      Map<String, String> headers = {
                        "Content-type": "application/json",
                        "Origin": "*",
                        "userid": userID,
                        "arduino": arduinoNum,
                        "rfid": rfidNum,
                        "corona": coronaStatus
                      };
                      Response response = await post(
                          'https://keep6.macrotechsolutions.us:9146/http://localhost/setupDevices',
                          headers: headers);
                      //createAlertDialog(context);
                      setupJSON = jsonDecode(response.body);
                      if (setupJSON["data"] == "Success") {
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('rfid', rfidNum);
                        prefs.setString('arduino', arduinoNum);
                        prefs.setString('corona', coronaStatus);
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }

                        Navigator.pushReplacementNamed(context, "/landing");
                      } else {
                        createAlertDialog(context, "Error", setupJSON["data"]);
                      }
                    },
                    child: Text("Submit"))),
          ],
        ),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  LandingPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class DrawCircle extends CustomPainter {
  Paint _paint;

  DrawCircle(color) {
    if(color == "green"){
      _paint = Paint()
        ..color = Colors.green
        ..strokeWidth = 10.0
        ..style = PaintingStyle.fill;
    } else if(color == "red"){
      _paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 10.0
        ..style = PaintingStyle.fill;
    } else{
      _paint = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 10.0
        ..style = PaintingStyle.fill;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), 100.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _LandingPageState extends State<LandingPage> {
  Future<String> createAlertDialog(BuildContext context, String title,
      String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    String result = "";
    var channel =
    IOWebSocketChannel.connect("wss://keep6.macrotechsolutions.us:4211");
    channel.stream.listen((message) async {
      print(message);
      var messageList = message.split(" ");
      print(messageList);
      if(messageList[0] == userID){
        print("here");
        setState((){
          color = messageList[1];
          distance = messageList[2];
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Keep6 Home"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Keep6\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                            'This screen will show you your risk of contracting COVID-19.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.playlist_add),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/whitelist");
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/settings");
              },
            ),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: CustomPaint(painter: DrawCircle(color)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Text("Distance: $distance feet", style: TextStyle(fontSize: 30),),
            ),
          ],
        ),
      ),
    );
  }
}

class WhitelistPage extends StatefulWidget {
  WhitelistPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WhitelistPageState createState() => _WhitelistPageState();
}

class _WhitelistPageState extends State<WhitelistPage> {
  Future<String> createAlertDialog(BuildContext context, String title,
      String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    String result = "";
    return Scaffold(
      appBar: AppBar(
        title: Text("Whitelist Users"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () async {
                return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: Text("Add User"),
                          content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Enter whitelist email address:"),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 10.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: 'Email address',
                                        hintText: "user@example.com"),
                                    onChanged: (String str) {
                                      setState(() {
                                        whitelistEmail = str;
                                      });
                                    },
                                  ),
                                ),
                              ]),
                          actions: <Widget>[
                            MaterialButton(
                              elevation: 5.0,
                              onPressed: () async {
                                Map<String, String> headers = {
                                  "Content-type": "application/json",
                                  "Origin": "*",
                                  "userid": userID,
                                  "email": whitelistEmail,
                                };
                                Response response = await post(
                                    'https://keep6.macrotechsolutions.us:9146/http://localhost/addWhitelist',
                                    headers: headers);
                                //createAlertDialog(context);
                                var tempJSON = jsonDecode(response.body);
                                if (tempJSON["data"] == "Failure") {
                                  createAlertDialog(context, "Error",
                                      "This user does not exist or is already in your whitelist. Please try again.");
                                } else {
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  if (prefs.getStringList('whitelist') == null) {
                                    prefs.setStringList(
                                        "whitelist", [whitelistEmail]);
                                    setState(() {
                                      whitelist = [whitelistEmail];
                                    });
                                  } else {
                                    setState(() {
                                      whitelist.add(whitelistEmail);
                                    });
                                    prefs.setStringList("whitelist", whitelist);
                                  }
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text("OK"),
                            )
                          ]);
                    });
              })
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/landing");
              },
            ),
            IconButton(
              icon: Icon(Icons.playlist_add),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/settings");
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: whitelist.length == null ? 1 : whitelist.length,
        itemBuilder: (context, position) {
          return ListTile(
              title: Text('${whitelist[position]}'),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () async {
                Map<String, String> headers = {
                  "Content-type": "application/json",
                  "Origin": "*",
                  "userid": userID,
                  "email": whitelist[position],
                };
                print(userID);
                print(whitelist[position]);
                Response response = await post(
                    'https://keep6.macrotechsolutions.us:9146/http://localhost/removeWhitelist',
                    headers: headers);
                //createAlertDialog(context);
                var tempJSON = jsonDecode(response.body);
                if (tempJSON["data"] == "Failure") {
                  createAlertDialog(context, "Error",
                      "An error has occured. Please contact support.");
                } else {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  if (whitelist.length == 1) {
                    prefs.remove("whitelist");
                    setState(() {
                      whitelist = [];
                    });
                  } else {
                    setState(() {
                      whitelist.remove(whitelist[position]);
                    });
                    prefs.setStringList("whitelist", whitelist);
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<String> createAlertDialog(BuildContext context, String title,
      String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    String result = "";
    return Scaffold(
      appBar: AppBar(
        title: Text("Keep6 Settings"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Keep6 Settings\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                            'This screen will allow you to edit the settings of this app.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/landing");
              },
            ),
            IconButton(
              icon: Icon(Icons.playlist_add),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/whitelist");
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            child: Text("Email Address: ${userJSON["email"]}",
                style: TextStyle(fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            child: Text(
              "Name: ${userJSON["name"]}",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 30.0, right: 30.0),
            child: Row(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, right: 15.0),
                    child: Text("Not you?", style: TextStyle(fontSize: 20))),
                RaisedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushReplacementNamed(context, "/");
                    },
                    child: Text("Sign out")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'RFID Access Code', hintText: "RFID Access Code"),
              keyboardType: TextInputType.number,
              onChanged: (String str) {
                setState(() {
                  rfidNum = str;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Reader Access Code',
                  hintText: "Reader Access Code"),
              keyboardType: TextInputType.number,
              onChanged: (String str) {
                setState(() {
                  arduinoNum = str;
                });
              },
            ),
          ),
          ListTile(
              title: RaisedButton(
                  onPressed: () async {
                    Map<String, String> headers = {
                      "Content-type": "application/json",
                      "Origin": "*",
                      "userid": userID,
                      "arduino": arduinoNum,
                      "rfid": rfidNum
                    };
                    Response response = await post(
                        'https://keep6.macrotechsolutions.us:9146/http://localhost/changeDevices',
                        headers: headers);
                    //createAlertDialog(context);
                    setupJSON = jsonDecode(response.body);
                    if (setupJSON["data"] == "Success") {
                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString('rfid', rfidNum);
                      prefs.setString('arduino', arduinoNum);
                      createAlertDialog(context, "Success",
                          "Updated RFID and Reader access keys.");
                    } else {
                      createAlertDialog(context, "Error", setupJSON["data"]);
                    }
                  },
                  child: Text("Update"))),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Row(
              children: <Widget>[
                Text("Do you have COVID-19?"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: DropdownButton(
                      items: [
                        DropdownMenuItem<String>(
                          value: "true",
                          child: Text(
                            "Yes",
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: "false",
                          child: Text(
                            "No",
                          ),
                        ),
                      ],
                      onChanged: (value) async {
                        setState(() {
                          coronaStatus = value;
                        });
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('coronaStatus', coronaStatus);
                      },
                      value: coronaStatus,
                      isExpanded: true,
                    ),
                  ),),
              ],
            ),
          ),
          ListTile(
              title: RaisedButton(
                  onPressed: () async {
                    Map<String, String> headers = {
                      "Content-type": "application/json",
                      "Origin": "*",
                      "userid": userID,
                      "corona": coronaStatus,
                    };
                    Response response = await post(
                        'https://keep6.macrotechsolutions.us:9146/http://localhost/changeStatus',
                        headers: headers);
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.setString("corona", coronaStatus);
                    createAlertDialog(context, "Success",
                        "Successfuly changed COVID-19 status.");
                  },
                  child: Text("Update"))),
        ],
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<String> createAlertDialog(BuildContext context, String title,
      String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    googleSignIn.signOut();
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Login\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text: 'Sign in to an existing Keep6 account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Email Address"),
                onChanged: (String str) {
                  setState(() {
                    username = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    password = str;
                  });
                },
              ),
            ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      Map<String, String> headers = {
                        "Content-type": "application/json",
                        "Origin": "*",
                        "email": username,
                        "password": password
                      };
                      Response response = await post(
                          'https://keep6.macrotechsolutions.us:9146/http://localhost/signIn',
                          headers: headers);
                      //createAlertDialog(context);
                      userJSON = jsonDecode(response.body);
                      if (userJSON["data"] != "Incorrect email address." &&
                          userJSON["data"] != "Incorrect Password") {
                        userID = userJSON["data"];
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('userID', userID);
                        prefs.setString('userJSON', response.body);
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }

                        Navigator.pushReplacementNamed(context, "/setup");
                      } else {
                        createAlertDialog(context, "Error", userJSON["data"]);
                      }
                    },
                    child: Text("Submit"))),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                "OR",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 50),
            RaisedButton(
              onPressed: () async {
                final GoogleSignInAccount googleSignInAccount =
                await googleSignIn.signIn();
                Map<String, String> headers = {
                  "Content-type": "application/json",
                  "Origin": "*",
                  "email": googleSignInAccount.email,
                  "name": googleSignInAccount.displayName
                };
                Response response = await post(
                    'https://keep6.macrotechsolutions.us:9146/http://localhost/googleSignIn',
                    headers: headers);
                //createAlertDialog(context);
                userJSON = jsonDecode(response.body);
                userID = userJSON["userkey"];
                var prefs = await SharedPreferences.getInstance();
                prefs.setString('userID', userID);
                prefs.setString('userJSON', response.body);
                dispose() {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  super.dispose();
                }

                Navigator.pushReplacementNamed(context, "/setup");
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/google_logo.png"),
                        height: 35.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Future<String> createAlertDialog(BuildContext context, String title,
      String body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future<String> helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    googleSignIn.signOut();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign Up\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text: 'Create a new Keep6 account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "First Name"),
                onChanged: (String str) {
                  setState(() {
                    firstName = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Last Name"),
                onChanged: (String str) {
                  setState(() {
                    lastName = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Email Address"),
                onChanged: (String str) {
                  setState(() {
                    username = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    password = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: InputDecoration(hintText: "Confirm Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    confirmPassword = str;
                  });
                },
              ),
            ),
            ListTile(
                title: RaisedButton(
                    onPressed: () async {
                      Map<String, String> headers = {
                        "Content-type": "application/json",
                        "Origin": "*",
                        "firstname": firstName,
                        "lastname": lastName,
                        "email": username,
                        "password": password,
                        "passwordconfirm": confirmPassword
                      };
                      Response response = await post(
                          'https://keep6.macrotechsolutions.us:9146/http://localhost/signUp',
                          headers: headers);
                      //createAlertDialog(context);
                      userJSON = jsonDecode(response.body);
                      if (userJSON["data"] != 'Email already exists.' &&
                          userJSON["data"] != 'Invalid Name' &&
                          userJSON["data"] != 'Invalid email address.' &&
                          userJSON["data"] !=
                              'Your password needs to be at least 6 characters.' &&
                          userJSON["data"] != 'Your passwords don\'t match.') {
                        userID = userJSON["userkey"];
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('userID', userID);
                        prefs.setString('userJSON', response.body);
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }

                        Navigator.pushReplacementNamed(context, "/setup");
                      } else {
                        createAlertDialog(context, "Error", userJSON["data"]);
                      }
                    },
                    child: Text("Submit"))),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                "OR",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 50),
            RaisedButton(
              onPressed: () async {
                final GoogleSignInAccount googleSignInAccount =
                await googleSignIn.signIn();
                Map<String, String> headers = {
                  "Content-type": "application/json",
                  "Origin": "*",
                  "email": googleSignInAccount.email,
                  "name": googleSignInAccount.displayName
                };
                Response response = await post(
                    'https://keep6.macrotechsolutions.us:9146/http://localhost/googleSignIn',
                    headers: headers);
                //createAlertDialog(context);
                userJSON = jsonDecode(response.body);
                userID = userJSON["userkey"];
                var prefs = await SharedPreferences.getInstance();
                prefs.setString('userID', userID);
                prefs.setString('userJSON', response.body);
                dispose() {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  super.dispose();
                }

                Navigator.pushReplacementNamed(context, "/setup");
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/google_logo.png"),
                        height: 35.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
