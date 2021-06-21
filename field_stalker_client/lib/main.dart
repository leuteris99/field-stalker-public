import 'package:field_stalker_client/Pages/homepage.dart';
import 'package:field_stalker_client/Pages/settingspage.dart';
import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Stalker',
      theme: ThemeData(
        // Collors guidelines: https://material.io/resources/color/#!/?view.left=0&view.right=0&primary.color=00796B&secondary.color=FFF176
        primarySwatch: Colors.teal,
        accentColor: Colors.yellow,
        unselectedWidgetColor: Colors.teal[900],
        textTheme: TextTheme(
          button: TextStyle(color: Colors.white),
          headline4: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: InitPage(title: 'Welcome to Field Stalker'),
    );
  }
}

class InitPage extends StatefulWidget {
  InitPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _InitPageState createState() => _InitPageState(title);
}

class _InitPageState extends State<InitPage> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  int _counter = 0;

  String title;

  _InitPageState(this.title);

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        print("Firebase connection Established.");
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return basicLayout(
        Center(
          child: Text("Error connecting to the server."),
        ),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return basicLayout(
        Center(
          child: Text("Loading..."),
        ),
      );
    }
    switch (_counter) {
      case 0:
        return basicLayout(HomePage());
        break;
      case 1:
        return basicLayout(SettingsPage());
        break;
      default:
        return basicLayout(Text("Error on NavBar"));
    }
  }

  Widget basicLayout(Widget body) {
    ThemeData _localTheme = Theme.of(context);

    return Scaffold(
      appBar: getScreenHeight(context) > getScreenWidth(context)
          ? AppBar(title: Center(child: Text(title)))
          : null,
      bottomNavigationBar: getScreenHeight(context) > getScreenWidth(context)
          ? BottomNavigationBar(
              selectedItemColor: _localTheme.accentColor,
              backgroundColor: _localTheme.primaryColor,
              currentIndex: _counter,
              onTap: (value) {
                setState(() {
                  _counter = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.stacked_bar_chart,
                  ),
                  label: "Stats",
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.settings,
                    ),
                    label: "Settings"),
              ],
            )
          : null,
      body: getScreenWidth(context) > getScreenHeight(context)
          ? landscapeLayout(body)
          : body,
    );
  }

  Widget landscapeLayout(Widget body) {
    ThemeData _localTheme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: getScreenWidth(context) / 4 < 400
              ? getScreenWidth(context) / 4
              : 400,
          color: Theme.of(context).primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 40,
              ),
              Center(
                child: Text(
                  title,
                  style: _localTheme.textTheme.headline4,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _counter = 0;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: getScreenWidth(context) / 4 < 400
                          ? getScreenWidth(context) / 10
                          : 150,
                    ),
                    Icon(
                      Icons.stacked_bar_chart,
                      color: _counter == 0
                          ? _localTheme.accentColor
                          : _localTheme.textTheme.button.color,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Stats',
                      style: _counter == 0
                          ? TextStyle(color: Colors.yellow)
                          : _localTheme.textTheme.button,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _counter = 1;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: getScreenWidth(context) / 4 < 400
                          ? getScreenWidth(context) / 10
                          : 150,
                    ),
                    Icon(
                      Icons.settings,
                      color: _counter == 1
                          ? _localTheme.accentColor
                          : _localTheme.textTheme.button.color,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Settings',
                      style: _counter == 1
                          ? TextStyle(color: Colors.yellow)
                          : _localTheme.textTheme.button,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
