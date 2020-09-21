import 'package:dotlive_schedule/calendar/calendar.dart';
import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_filter_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<CalendarManager, CalendarFilterOption>(
        builder: (context, manager, op, _) {
      final calendarRes = manager.getCalendarResponse(manager.currentDate);
      final actions = (calendarRes != null && calendarRes.actors.length > 0)
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
                          return _buildDialog(context, op, calendarRes.actors,
                              filters, setState);
                        });
                      });
                },
              )
            ]
          : null;

      return AppBar(
        title: Text(_formatDate(manager.currentDate)),
        actions: actions,
      );
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  String _formatDate(DateTimeJST d) {
    return '${d.year}年${d.month}月';
  }

  Widget _buildDialog(BuildContext context, CalendarFilterOption op,
      List<CalendarActor> actors, Set<String> filters, StateSetter setState) {
    final switches = actors
        .map((actor) => _buildSwitchListTile(
                context, Text(actor.name), !filters.contains(actor.id), (v) {
              setState(() {
                if (filters.contains(actor.id)) {
                  filters.remove(actor.id);
                } else {
                  filters.add(actor.id);
                }
              });
            }))
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
                  },
                  shape: StadiumBorder(),
                  child: Text("全選択")),
              RaisedButton(
                  onPressed: () {
                    setState(() {
                      filters.clear();
                      filters.addAll(actors.map((a) => a.id));
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
        FlatButton(
            onPressed: () {
              op.update(filters);
              Navigator.of(context).pop();
            },
            child: Text("OK")),
      ],
    );
  }

  Widget _buildSwitchListTile(BuildContext context, Widget title, bool value,
      ValueChanged<bool> onChanged) {
    // 標準のSwitchListTileはswitchを切り替えたときにFeedback.forTapが存在しないので付け加える

    final trailing = Switch(
      value: value,
      onChanged: (v) {
        Feedback.forTap(context);
        onChanged(v);
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: Theme.of(context).accentColor,
        child: ListTile(
          title: title,
          trailing: trailing,
          enabled: onChanged != null,
          onTap: onChanged != null
              ? () {
                  onChanged(!value);
                }
              : null,
        ),
      ),
    );
  }
}
