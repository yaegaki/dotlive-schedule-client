import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/schedule/schedule_manager.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_filter_option.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();

    final manager = Provider.of<CalendarManager>(context, listen: false);
    manager.fetchCalendar(manager.currentDate, false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarManager>(builder: (context, manager, _) {
      final calendarRes = manager.getCalendarResponse(manager.currentDate);
      if (calendarRes == null) {
        return Text("loading...");
      }

      final filterOption = Provider.of<CalendarFilterOption>(context);
      Future(() {
        if (filterOption.enabled) return;
        filterOption.setActors(calendarRes.actors);
      });

      final createAvatar = (String icon) {
        return Expanded(
            flex: 1,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                        child: CircleAvatar(
                      backgroundImage: NetworkImage(icon),
                    )))));
      };

      final Color themeColor =
          Theme.of(context).colorScheme.onSurface.withOpacity(0.12);
      final f = (int index, int i, List<String> icons, int filtered) {
        final title = i > 0 ? i.toString() : "";
        List<Widget> widgets = List<Widget>();
        widgets.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          alignment: Alignment.topLeft,
          width: 9900,
          // color: Colors.blue,
          child: Text(title),
        ));
        if (icons != null) {
          List<Widget> ww = [];
          for (int i = 0; i < 2; i++) {
            if (i >= icons.length) {
              ww.add(Expanded(flex: 1, child: Container()));
            } else {
              ww.add(createAvatar(icons[i]));
            }
          }
          widgets.add(Row(children: ww));

          ww = [];
          for (int i = 2; i < 4; i++) {
            if (i >= icons.length) {
              ww.add(Expanded(flex: 1, child: Container()));
            } else {
              ww.add(createAvatar(icons[i]));
            }
          }
          widgets.add(Row(children: ww));

          List<Widget> bottomWidgets;
          if (filtered > 0) {
            if (bottomWidgets == null) bottomWidgets = List<Widget>();

            bottomWidgets.add(Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.remove_circle_outline,
                      size: 10,
                    ),
                    Text(
                      filtered.toString(),
                      style: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 10),
                    ),
                  ],
                )));
          }

          if (icons.length > 4) {
            if (bottomWidgets == null) bottomWidgets = List<Widget>();
            bottomWidgets.add(Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "+${icons.length - 4}",
                  style: TextStyle(
                      color: Theme.of(context).hintColor, fontSize: 10),
                )));
          }

          if (bottomWidgets != null) {
            widgets.add(Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                child: Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: bottomWidgets),
              ),
            ));
          }
        }

        return Expanded(child: Consumer<ScheduleManager>(
          builder: (context, scheduleManager, _) {
            final backgroundColor = (index % 7) % 2 == 0
                ? Theme.of(context).dividerColor
                : Colors.transparent;
            return Padding(
              // padding: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.alphaBlend(
                                backgroundColor, themeColor)))),
                child: FlatButton(
                  shape: Border(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (i < 1) return;
                    final targetDate = DateTimeJST.jst(
                        calendarRes.calendar.baseDate.year,
                        calendarRes.calendar.baseDate.month,
                        i);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: scheduleManager),
                        ],
                        child: CalendarSchedulePage(targetDate),
                      );
                    }));
                  },
                  child: Container(
                      color: backgroundColor,
                      child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(height: 86),
                          child: Column(children: widgets))),
                ),
              ),
            );
          },
        ));
      };

      final baseDate = calendarRes.calendar.baseDate;
      final begin = DateTimeJST.jst(baseDate.year, baseDate.month, 1);
      final days = List<int>();
      // 1行に7個並べる
      // 並びは"日月火水木金土"
      // 月初が日曜日以外の場合は途中から始める
      if (begin.weekday != DateTime.sunday) {
        // weekdayは月曜が1、日曜が7
        for (int i = 0; i < begin.weekday; i++) {
          days.add(-1);
        }
      }
      for (DateTimeJST d = begin;
          d.month == begin.month;
          d = d.add(Duration(days: 1))) {
        days.add(d.day);
      }

      final rows = List<Widget>();
      for (int i = 0; i < days.length;) {
        final end = i + 7;
        final columns = List<Widget>();
        for (; i < end; i++) {
          final day = i < days.length ? days[i] : -1;
          final ids = calendarRes.calendar.dayMap.getActorIds(day);
          List<String> icons;
          int filtered = 0;
          if (ids != null) {
            icons = List<String>();
            ids.forEach((id) {
              if (filterOption.filters.contains(id)) {
                filtered++;
                return;
              }

              icons.add(calendarRes.actors.firstWhere((a) => a.id == id).icon);
            });
          }
          columns.add(f(i, day, icons, filtered));
        }
        rows.add(Row(children: columns));
      }

      return LayoutBuilder(builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () => manager.fetchCalendar(manager.currentDate, true),
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: themeColor)),
                      ),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: Align(
                                alignment: Alignment.center, child: Text("日"))),
                        Expanded(
                            child: Align(
                                alignment: Alignment.center, child: Text("月"))),
                        Expanded(
                            child: Align(
                                alignment: Alignment.center, child: Text("火"))),
                        Expanded(
                            child: Align(
                                alignment: Alignment.center, child: Text("水"))),
                        Expanded(
                            child: Align(
                                alignment: Alignment.center, child: Text("木"))),
                        Expanded(
                            child: Align(
                                alignment: Alignment.center, child: Text("金"))),
                        Expanded(
                            child: Align(
                                alignment: Alignment.center, child: Text("土"))),
                      ]),
                    ),
                    Column(children: rows),
                  ],
                ),
              )),
        );
      });
    });
  }
}
