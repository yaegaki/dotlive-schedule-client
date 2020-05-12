import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CalendarDrawer extends StatelessWidget {
  Widget build(BuildContext context) {
    final manager = Provider.of<CalendarManager>(context, listen: false);
    var children = <Widget>[];
    final now = DateTimeJST.now();

    var date = DateTimeJST.fromYM(CalendarManager.calendarBeginDate);
    const month = Duration(days: 32);
    var initialIndex = 0;
    for (var i = 0; date.before(now); i++) {
      final _date = date;
      final selected = _date.year == manager.currentDate.year &&
          _date.month == manager.currentDate.month;
      children.add(ListTile(
        selected: selected,
        title: Text(_formatDate(_date)),
        onTap: () {
          manager.setCurrentDate(_date);
          Navigator.of(context).pop();
        },
      ));
      if (selected) {
        initialIndex = i;
      }

      date = DateTimeJST.fromYM(_date.add(month));
    }

    children = children.reversed.toList();
    initialIndex = children.length - initialIndex - 1;

    final padding = MediaQuery.of(context).padding;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: 80 + padding.top),
          child: DrawerHeader(
            padding: EdgeInsets.fromLTRB(16.0 + padding.left, 16.0, 16.0, 8.0),
            child: Text('表する月を選択'),
          )),
          Expanded(
            child: ScrollablePositionedList.builder(
                initialScrollIndex: initialIndex,
                // todo:
                // initialAlignmentを設定しないとバウンスしてしまう
                // しかし要素が少なすぎるときに設定するとアサートに引っ掛かってしまう
                // https://github.com/google/flutter.widgets/issues/38
                initialAlignment: 0,
                itemCount: children.length,
                itemBuilder: (context, index) {
                  return children[index];
                }),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTimeJST d) {
    return '${d.year}年${d.month}月';
  }
}
