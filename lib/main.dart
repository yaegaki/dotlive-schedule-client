import 'package:dotlive_schedule/datetime_jst.dart';
import 'package:dotlive_schedule/schedule_manager.dart';
import 'package:dotlive_schedule/sort_option.dart';
import 'package:dotlive_schedule/widgets/schedule_app_bar.dart';
import 'package:dotlive_schedule/widgets/schedule_page.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _token = "";
  int _selectedIndex = 0;
  DateTimeJST _startDate;
  PageController _pageController;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

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

    _startDate = DateTimeJST.now();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_selectedIndex == 0) {
      child = SchedulePage(_startDate);
    } else {
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScheduleManager>(
          create: (_) => ScheduleManager(_startDate),
        ),
        ChangeNotifierProvider<SortOption>(
          create: (_) => SortOption(),
        ),
      ],
      child: Scaffold(
        appBar: ScheduleAppBar(),
        body: child,
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
              label: 'スケジュール',
            ),
            FFNavigationBarItem(
              iconData: Icons.history,
              label: '履歴',
            ),
            FFNavigationBarItem(
              iconData: Icons.settings,
              label: '設定',
            )
          ],
        ),
      ),
    );
  }
}
