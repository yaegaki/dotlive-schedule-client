import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/messaging/messaging_manager.dart';
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
import 'package:provider/provider.dart';

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

    return Consumer<MessagingManager>(builder: (context, messagingManager, _) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ScheduleManager>(
            create: (_) => ScheduleManager(messagingManager, _startDate),
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
    });
  }
}
