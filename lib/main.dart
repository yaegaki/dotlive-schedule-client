import 'package:dotlive_schedule/schedule_list.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  DateTime _startDate;
  PageController _pageController;
  int _selectedPageIndex = 0;

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

    _pageController = PageController(initialPage: 6);
    _selectedPageIndex = _pageController.initialPage;
    _startDate = DateTime.now().toUtc().subtract(Duration(days: 6));
    final s = _startDate.add(Duration(hours: 9)).add(Duration(days: 6));
    const weekLabels = '日月火水木金土日';
    _pt = '${s.year}/${s.month}月${s.day}日(${weekLabels[s.weekday]})';
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_selectedIndex == 0) {
      child = PageView.builder(
        // controller: _pageController,
        controller: _pageController,
        itemBuilder: (_, index) {
          final date = _startDate.add(Duration(days: index));
          return ScheduleList(date);
        },
        onPageChanged: (pageIndex) {
          setState(() {
            final s = _startDate.add(Duration(hours: 9)).add(Duration(days: pageIndex));
            const weekLabels = '日月火水木金土日';
            _pt = '${s.year}/${s.month}月${s.day}日(${weekLabels[s.weekday]})';
            _selectedPageIndex = pageIndex;
          });
        },
      );
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

    final now = DateTime.now().toUtc().add(Duration(hours: 9));
    final shownDate = _startDate.add(Duration(days: _selectedPageIndex, hours: 9));
    final diffDays = shownDate.difference(now).inDays;
    List<Widget> actions;
    if (diffDays != 0 || now.day != shownDate.day) {
      actions = [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            final diff = DateTime.now().difference(_startDate).inDays;
            _pageController.jumpToPage(diff);
          }
        ),
      ];
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
        actions: actions,
      ),
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
