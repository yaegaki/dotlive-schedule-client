import 'package:dotlive_schedule/datetime_jst.dart';
import 'package:dotlive_schedule/schedule_manager.dart';
import 'package:dotlive_schedule/sort_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ScheduleAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ScheduleManager>(context, listen: false);

    return Selector<ScheduleManager, DateTimeJST>(
      selector: (_, m) => m.currentDate,
      builder: (_, d, child) {
        final action = _isToday(d)
            ? null
            : IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => manager.setCurrentDate(DateTimeJST.now()));
        return AppBar(
          title: Text(_createTitle(d)),
          leading: child,
          actions: action == null ? null : [action],
        );
      },
      child: Consumer<SortOption>(builder: (_, op, __) {
        return IconButton(
          icon: Icon(Icons.sort),
          onPressed: () => op.update(!op.asc),
        );
      }),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  static bool _isToday(DateTimeJST d) => DateTimeJST.now().differenceDay(d) == 0;

  static String _createTitle(DateTimeJST d) {
    const weekLabels = '日月火水木金土日';
    return '${d.year}年${d.month}月${d.day}日(${weekLabels[d.weekday]})';
  }
}
