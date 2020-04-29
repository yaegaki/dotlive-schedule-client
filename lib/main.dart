import 'package:dotlive_schedule/datetime_jst.dart';
import 'package:dotlive_schedule/schedule_manager.dart';
import 'package:dotlive_schedule/sort_option.dart';
import 'package:dotlive_schedule/widgets/schedule_app_bar.dart';
import 'package:dotlive_schedule/widgets/schedule_page.dart';
import 'package:dotlive_schedule/widgets/settings_app_bar.dart';
import 'package:dotlive_schedule/widgets/settings_page.dart';
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
      title: 'DotliveSchedule',
      theme: ThemeData(
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
  int _selectedIndex = 0;
  DateTimeJST _startDate;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.subscribeToTopic('plan');

    _startDate = DateTimeJST.now();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    PreferredSizeWidget appBar;
    if (_selectedIndex == 0) {
      child = SchedulePage(_startDate);
      appBar = ScheduleAppBar();
    } else {
      child = SettingsPage();
      appBar = SettingsAppBar();
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
        appBar: appBar,
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
              iconData: Icons.settings,
              label: '設定',
            )
          ],
        ),
      ),
    );
  }
}
