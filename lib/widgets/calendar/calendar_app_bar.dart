import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_filter_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<CalendarManager, CalendarFilterOption>(builder: (context, manager, op, _) {
      final actions = op.enabled
          ? <Widget>[
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        Set<String> filters = op.filters.toSet();
                        return StatefulBuilder(builder: (context, setState) {
                          return _buildDialog(context, op, filters, setState);
                        });
                      });
                },
              )
            ]
          : <Widget>[];
      actions.add(IconButton(
        icon: Icon(Icons.cloud_circle),
        onPressed: () {
          manager.fetchCalendar(manager.currentDate, true);
        },
      ));
      actions.add(IconButton(
        icon: Icon(Icons.remove),
        onPressed: () {
          manager.clearAll();
        },
      ));
      actions.add(IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          final c = manager.currentDate;
          DateTimeJST date;
          if (c.month == 1) {
            date = DateTimeJST.jst(c.year - 1, 12);
          } else {
            date = DateTimeJST.jst(c.year, c.month - 1);
          }
          manager.setCurrentDate(date);
        },
      ));
      actions.add(IconButton(
        icon: Icon(Icons.arrow_forward),
        onPressed: () {
          final c = manager.currentDate;
          DateTimeJST date;
          if (c.month == 12) {
            date = DateTimeJST.jst(c.year + 1, 1);
          } else {
            date = DateTimeJST.jst(c.year, c.month + 1);
          }
          manager.setCurrentDate(date);
        },
      ));
      return AppBar(
        title: Text('${manager.currentDate.year}年${manager.currentDate.month}月'),
        actions: actions,
      );
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Widget _buildDialog(BuildContext context, CalendarFilterOption op,
      Set<String> filters, StateSetter setState) {
    final switches = op.actors
        .map((actor) => SwitchListTile(
            onChanged: (v) {
              setState(() {
                if (filters.contains(actor.id)) {
                  filters.remove(actor.id);
                } else {
                  filters.add(actor.id);
                }
              });
            },
            value: !filters.contains(actor.id),
            title: Text(actor.name)))
        .toList();
    return AlertDialog(
      title: Text('絞り込み'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 10.0),
      content: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                  onPressed: () {
                    setState(() {
                      filters.clear();
                    });
                  }, shape: StadiumBorder(), child: Text("全選択")),
              RaisedButton(
                  onPressed: () {
                    setState(() {
                      filters.clear();
                      filters.addAll(op.actors.map((a) => a.id));
                    });
                  },
                  shape: StadiumBorder(),
                  child: Text("全選択解除")),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: switches,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel")),
        FlatButton(onPressed: () {
          op.update(filters);
          Navigator.of(context).pop();
        }, child: Text("OK")),
      ],
    );
  }
}
