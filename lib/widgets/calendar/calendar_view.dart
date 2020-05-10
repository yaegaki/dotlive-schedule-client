import 'package:dotlive_schedule/calendar/calendar.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/schedule/schedule_manager.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_filter_option.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CalendarView extends StatelessWidget {
  final Calendar _calendar;
  final Map<String, CalendarActor> _actorMap;

  CalendarView(this._calendar, List<CalendarActor> actors)
      : _actorMap = Map<String, CalendarActor>.fromEntries(
            actors.map((a) => MapEntry<String, CalendarActor>(a.id, a)));

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarFilterOption>(builder: (context, filterOption, _) {
      final children = <Widget>[
        _buildWeekdayLabel(context),
      ];

      children.addAll(_buildDays(context, filterOption));

      return Column(
        children: children,
      );
    });
  }

  Widget _buildWeekdayLabel(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(children: <Widget>[
        Expanded(child: Align(alignment: Alignment.center, child: Text("日"))),
        Expanded(child: Align(alignment: Alignment.center, child: Text("月"))),
        Expanded(child: Align(alignment: Alignment.center, child: Text("火"))),
        Expanded(child: Align(alignment: Alignment.center, child: Text("水"))),
        Expanded(child: Align(alignment: Alignment.center, child: Text("木"))),
        Expanded(child: Align(alignment: Alignment.center, child: Text("金"))),
        Expanded(child: Align(alignment: Alignment.center, child: Text("土"))),
      ]),
    );
  }

  Iterable<Widget> _buildDays(
      BuildContext context, CalendarFilterOption filterOption) sync* {
    final theme = Theme.of(context);
    final evenBackgroundColor = Colors.transparent;
    final oddBackgroundColor = theme.dividerColor;
    final borderColor = theme.dividerColor;

    final baseDate = _calendar.baseDate;
    var date = DateTimeJST.jst(baseDate.year, baseDate.month, 1);

    var days = <Widget>[];

    if (date.weekday != DateTime.sunday) {
      days.addAll(List.generate(
          date.weekday,
          (i) => _buildBlankDay(
              context,
              i % 2 == 0 ? evenBackgroundColor : oddBackgroundColor,
              borderColor)));
    }

    while (baseDate.month == date.month) {
      days = days ?? <Widget>[];

      for (var i = days.length; i < 7; i++) {
        final backgroundColor =
            i % 2 == 0 ? evenBackgroundColor : oddBackgroundColor;
        if (baseDate.month == date.month) {
          days.add(_buildDay(
              context, date.day, filterOption, backgroundColor, borderColor));
        } else {
          days.add(_buildBlankDay(context, backgroundColor, borderColor));
        }

        date = date.add(Duration(days: 1));
      }

      yield Row(children: days);
      days = null;
    }
  }

  Widget _buildBlankDay(
      BuildContext context, Color backgroundColor, Color borderColor) {
    return _buildDayCore(
        context, -1, 0, const <String>[], backgroundColor, borderColor);
  }

  Widget _buildDay(
      BuildContext context,
      int day,
      CalendarFilterOption filterOption,
      Color backgroundColor,
      Color borderColor) {
    var filtered = 0;
    final actorIcons = <String>[];
    for (final id in _calendar.dayMap.getActorIds(day)) {
      if (filterOption.filters.contains(id)) {
        filtered++;
        continue;
      }

      final actor = _actorMap[id];
      if (actor == null) {
        continue;
      }

      actorIcons.add(actor.icon);
    }

    return _buildDayCore(
        context, day, filtered, actorIcons, backgroundColor, borderColor);
  }

  Widget _buildDayCore(BuildContext context, int day, int filtered,
      List<String> actorIcons, Color backgroundColor, Color borderColor) {
    return Consumer<ScheduleManager>(builder: (context, scheduleManager, _) {
      final children = <Widget>[];

      // 日付
      children.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        alignment: Alignment.topLeft,
        child: Text(day > 0 ? day.toString() : ''),
      ));

      // アイコン
      for (int i = 0; i < 2; i++) {
        final actorIconBaseIndex = i * 2;

        final icons = List<Widget>(2);
        for (int j = 0; j < 2; j++) {
          final actorIconIndex = actorIconBaseIndex + j;
          final child = actorIconIndex >= actorIcons.length
              ? _buildActorIconPlaceholder()
              : _buildActorIcon(actorIcons[actorIconIndex]);
          icons[j] = Expanded(child: child);
        }
        children.add(Row(children: icons));
      }

      final bottomWidgets = <Widget>[];
      final bottomWidgetTextStyle =
          TextStyle(color: Theme.of(context).hintColor, fontSize: 10);
      // フィルターされた数表示
      if (filtered > 0) {
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
                  style: bottomWidgetTextStyle,
                ),
              ],
            )));
      }

      // 入りきらなかった配信者の数表示
      if (actorIcons.length > 4) {
        bottomWidgets.add(Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '+${actorIcons.length - 4}',
              style: bottomWidgetTextStyle,
            )));
      }

      // placeholder
      if (bottomWidgets.length == 0) {
        bottomWidgets.add(Text('', style: bottomWidgetTextStyle));
      }

      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: bottomWidgets),
      ));

      return Expanded(
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Color.alphaBlend(backgroundColor, borderColor)))),
          child: FlatButton(
              // 角を四角にする
              shape: Border(),
              padding: EdgeInsets.zero,
              onPressed: () => _showSchedulePage(context, day, scheduleManager),
              child: Container(
                  color: backgroundColor, child: Column(children: children))),
        ),
      );
    });
  }

  Widget _buildActorIconPlaceholder() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: AspectRatio(aspectRatio: 1, child: Container()));
  }

  Widget _buildActorIcon(String url) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
                // circleAvatarにボーダーをつけるために二重にする
                child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Container(
                padding: EdgeInsets.all(1),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(url),
                ),
              ),
            ))));
  }

  void _showSchedulePage(
      BuildContext context, int day, ScheduleManager scheduleManager) {
    if (day < 1) return;
    final targetDate =
        DateTimeJST.jst(_calendar.baseDate.year, _calendar.baseDate.month, day);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: scheduleManager),
        ],
        child: CalendarSchedulePage(targetDate),
      );
    }));
  }
}
