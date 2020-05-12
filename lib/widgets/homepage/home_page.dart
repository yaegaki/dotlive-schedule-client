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

// FFNavigationBarからほぼ全てコピペ
// セーフエリア関連の計算が間違えていたのでそこだけ修正している
class FFNavigationBar extends StatefulWidget {
  final Function onSelectTab;
  final List<FFNavigationBarItem> items;
  final FFNavigationBarTheme theme;

  final int selectedIndex;

  FFNavigationBar({
    Key key,
    this.selectedIndex = 0,
    @required this.onSelectTab,
    @required this.items,
    @required this.theme,
  }) {
    assert(items != null);
    assert(items.length >= 2 && items.length <= 5);
    assert(onSelectTab != null);
  }

  @override
  _FFNavigationBarState createState() =>
      _FFNavigationBarState(selectedIndex: selectedIndex);
}

class _FFNavigationBarState extends State<FFNavigationBar> {
  int selectedIndex;
  _FFNavigationBarState({this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final FFNavigationBarTheme theme = widget.theme;
    final bgColor =
        theme.barBackgroundColor ?? Theme.of(context).bottomAppBarColor;

    return MultiProvider(
      providers: [
        Provider<FFNavigationBarTheme>.value(value: theme),
        Provider<int>.value(value: widget.selectedIndex),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: theme.barHeight,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.items.map((item) {
                var index = widget.items.indexOf(item);
                item.setIndex(index);

                final mediaQueryData = MediaQuery.of(context);
                final width = mediaQueryData.size.width -
                    (mediaQueryData.padding.left +
                        mediaQueryData.padding.right);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onSelectTab(index);
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: width / widget.items.length,
                      height: theme.barHeight,
                      child: item,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
