import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/schedule/schedule_manager.dart';
import 'package:dotlive_schedule/schedule/schedule_sort_option.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_app_bar.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_drawer.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_filter_option.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_page.dart';
import 'package:dotlive_schedule/widgets/schedule/schedule_app_bar.dart';
import 'package:dotlive_schedule/widgets/schedule/schedule_page.dart';
import 'package:dotlive_schedule/widgets/settings/settings_app_bar.dart';
import 'package:dotlive_schedule/widgets/settings/settings_page.dart';
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
    const MaterialColor primaryColorSwatch = MaterialColor(
      0xff00a3ef,
      <int, Color>{
        50:  Color(0xffe8f8ff),
        100: Color(0xffc5ecff),
        200: Color(0xff9fe0ff),
        300: Color(0xff79d4ff),
        400: Color(0xff5ccaff),
        500: Color(0xff3fc1ff),
        600: Color(0xff39bbff),
        700: Color(0xff31b3ff),
        800: Color(0xff29abff),
        900: Color(0xff1b9eff),
      },
    );

    const darkAccentColor = Color(0xff00a3ef);

    return MaterialApp(
      title: 'DotliveSchedule',
      theme: ThemeData(
        primarySwatch: primaryColorSwatch,
      ),
      darkTheme: ThemeData.dark().copyWith(
        accentColor: darkAccentColor,
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
    Widget drawer;
    switch (_selectedIndex) {
      case 0:
        child = SchedulePage(_startDate);
        appBar = ScheduleAppBar();
        break;
      case 1:
        child = CalendarPage();
        appBar = CalendarAppBar();
        drawer = CalendarDrawer();
        break;
      default:
        child = SettingsPage();
        appBar = SettingsAppBar();
        break;
    }

    final themeData = Theme.of(context);

    Color selectedItemColor; 
    switch (themeData.brightness) {
      case Brightness.light:
        selectedItemColor = themeData.primaryColor;
        break;
      case Brightness.dark:
        selectedItemColor = themeData.accentColor;
        break;
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScheduleManager>(
          create: (_) => ScheduleManager(_startDate),
        ),
        ChangeNotifierProvider<ScheduleSortOption>(
          create: (_) => ScheduleSortOption(),
        ),
        ChangeNotifierProvider<CalendarManager>(
          create: (_) => CalendarManager(_startDate),
        ),
        ChangeNotifierProvider<CalendarFilterOption>(
          create: (_) => CalendarFilterOption(),
        ),
      ],
      child: Scaffold(
        appBar: appBar,
        drawer: drawer,
        body: child,
        bottomNavigationBar: FFNavigationBar(
          theme: FFNavigationBarTheme(
            barBackgroundColor: themeData.canvasColor,
            selectedItemBackgroundColor: selectedItemColor,
            selectedItemIconColor: themeData.canvasColor,
            selectedItemBorderColor: themeData.canvasColor,
            selectedItemLabelColor: selectedItemColor,
            showSelectedItemShadow: false,
          ),
          selectedIndex: _selectedIndex,
          onSelectTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            FFNavigationBarItem(
              iconData: Icons.bookmark,
              label: 'スケジュール',
            ),
            FFNavigationBarItem(
              iconData: Icons.calendar_today,
              label: 'カレンダー',
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
