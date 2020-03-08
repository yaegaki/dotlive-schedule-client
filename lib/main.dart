import 'dart:convert';

import 'package:dotlive_schedule/schedule.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _pt = "";
  int _counter = 0;
  String _token = "";
  int _selectedIndex = 0;
  Schedule _schedule;
  int _scheduleIndex = 0;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true
      )
    );

    _firebaseMessaging.getToken().then((s) {
      setState(() {
        _token = s;
      });
    });

    _firebaseMessaging.onTokenRefresh.listen((s) {
      setState(() {
        _token = s;
      });
    });

    _token = "test";
    fetchSchedule(_scheduleIndex);
  }

  void fetchSchedule(int scheduleIndex) {
    final scheduleURL = 'https://dotlive-schedule.appspot.com?q=$scheduleIndex';
    setState(() {
      _scheduleIndex = scheduleIndex;
      _schedule = null;
    });

    http.get(scheduleURL).then((res) {
      final schedule = Schedule.fromJSON(jsonDecode(res.body));
      setState(() {
        _schedule = schedule;
        final s = _schedule.date.add(Duration(hours: 9));
        const weekLabels = '日月火水木金土日';
        _pt = '${s.year}/${s.month}月${s.day}日(${weekLabels[s.weekday]})';
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_selectedIndex == 0) {
      if (_schedule == null)
      {
        child = Center(
          child: Text('now loading...'),
        );
      }
      else
      {
        child = ListView.builder(
          itemBuilder: (context, index) {
            final e = _schedule.entries[index];
            final s = e.startAt.add(Duration(hours: 9));

            final title = '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}~ ${e.actorName}';
            final url = e.icon;

            String body;
            bool hasTrailing;
            if (e.text == '') {
              body = '配信予定';
              hasTrailing = false;
            }
            else {
              body = e.text;
              hasTrailing = true;
            }

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(url),
                  maxRadius: 25,
                  minRadius: 25,
                ),
                title: Text(title),
                subtitle: Text(body),
                isThreeLine: true,
                trailing: hasTrailing ? Icon(Icons.keyboard_arrow_right) : null,
                onTap: () async {
                  if (e.url != '') {
                    if (await canLaunch(e.url)) {
                      await launch(e.url);
                    }
                  }
                },
              )
            );
          },
          itemCount: _schedule.entries.length,
        );
      }
    }
    else {
      child = Center(
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
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              '$_token',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      );
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(_pt == '' ? widget.title : _pt),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            fetchSchedule(_scheduleIndex - 1);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.keyboard_arrow_right),
            onPressed: () => fetchSchedule(_scheduleIndex + 1),
          ),
        ],
      ),
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBackgroundColor: Colors.green,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
        selectedIndex: _selectedIndex,
        onSelectTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.calendar_today,
            label: 'Schedule',
          ),
          FFNavigationBarItem(
            iconData: Icons.people,
            label: 'Contacts',
          ),
        ],
      ),
    );
  }
}
