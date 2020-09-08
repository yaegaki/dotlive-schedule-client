import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/schedule/schedule_manager.dart';
import 'package:dotlive_schedule/schedule/schedule_sort_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTimeJST targetDate;

  ScheduleAppBar({this.targetDate});

  @override
  Widget build(BuildContext context) {
    final hasTargetDate = targetDate != null;

    return Consumer<ScheduleManager>(
      builder: (_, m, child) {
        final d = hasTargetDate ? targetDate : m.currentDate;
        List<Widget> actions;
        if (!hasTargetDate && !_isToday(d)) {
          actions = [
            IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => m.setCurrentDate(DateTimeJST.now()))
          ];
        }

        final schedule = m.getSchedule(d);
        if (schedule != null &&
            schedule.tweetId != null &&
            schedule.tweetId.isNotEmpty) {
          actions = actions == null ? [] : actions;
          final tweetId = schedule.tweetId;
          actions.add(IconButton(
              icon: Icon(Icons.info),
              onPressed: () async {
                final tweetURL =
                    "https://twitter.com/dotLIVEyoutuber/status/$tweetId";
                if (await canLaunch(tweetURL)) {
                  await launch(tweetURL, forceSafariVC: false);
                }
              }));
        }

        return AppBar(
          title: Text(_createTitle(d)),
          leading: child,
          actions: actions,
        );
      },
      child: hasTargetDate ? null : Consumer<ScheduleSortOption>(builder: (_, op, __) {
        return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(1.0, op.asc ? -1.0 : 1.0, 1.0),
            child: IconButton(
              icon: Icon(Icons.sort),
              onPressed: () => op.update(!op.asc),
            ));
      }),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  static bool _isToday(DateTimeJST d) =>
      DateTimeJST.now().differenceDay(d) == 0;

  static String _createTitle(DateTimeJST d) {
    const weekLabels = '日月火水木金土日';
    return '${d.year}年${d.month}月${d.day}日(${weekLabels[d.weekday]})';
  }
}
