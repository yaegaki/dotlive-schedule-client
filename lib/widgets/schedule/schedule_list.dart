import 'package:dotlive_schedule/common/constants.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/schedule/schedule.dart';
import 'package:dotlive_schedule/schedule/schedule_manager.dart';
import 'package:dotlive_schedule/schedule/schedule_sort_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleList extends StatelessWidget {
  final DateTimeJST date;
  final bool canControl;

  ScheduleList(this.date, {this.canControl = true});

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<ScheduleManager>(context, listen: false);

    return Selector<ScheduleManager, Schedule>(
      selector: (_, m) => m.getSchedule(date),
      builder: (_, schedule, __) {
        if (schedule == null) {
          return Center(child: CircularProgressIndicator());
        }

        int itemCount;
        if (schedule.hasError || schedule.entries.length == 0) {
          itemCount = 1;
        } else {
          itemCount = schedule.entries.length;
        }

        final buildListView = (bool asc) {
          final existsBottomBar = canControl;
          var padding = MediaQuery.of(context).padding;
          if (existsBottomBar) {
            padding = padding.copyWith(bottom: defaultBottomMargin);
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            itemBuilder: (_, index) {
              if (schedule.hasError) {
                return _buildTextCard('エラーが発生しました');
              }

              if (schedule.entries.length == 0) {
                return _buildTextCard('予定がありません');
              }

              if (!asc) {
                index = schedule.entries.length - 1 - index;
              }

              return _buildCard(schedule.date, schedule.entries[index]);
            },
            itemCount: itemCount,
          );
        };

        Widget child;
        if (canControl) {
          child = Consumer<ScheduleSortOption>(
              builder: (_, op, __) => buildListView(op.asc));
        } else {
          child = buildListView(true);
        }

        return RefreshIndicator(
          onRefresh: () => manager.fetchSchedule(date, true),
          child: child,
        );
      },
    );
  }

  Widget _buildTextCard(String text) {
    return Card(
        child: ListTile(
      title: Text(text),
    ));
  }

  Widget _buildCard(DateTimeJST baseDate, ScheduleEntry entry) {
    final d = entry.startAt;
    final diff = d.differenceDay(baseDate);
    final hour = diff > 0 ? diff * 24 + d.hour : d.hour;

    final title =
        '${hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}~ ${entry.actorName}';
    final icon = entry.icon;

    String body;
    bool hasTrailing;
    if (entry.text == '') {
      body = '配信予定';
      hasTrailing = false;
    } else {
      body = entry.text;
      hasTrailing = true;
    }

    return Card(
        child: ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(icon),
        maxRadius: 25,
        minRadius: 25,
      ),
      title: Text(title),
      subtitle: Text(body),
      isThreeLine: true,
      trailing: hasTrailing ? Icon(Icons.keyboard_arrow_right) : null,
      onTap: () async {
        if (entry.url == '') return;
        if (await canLaunch(entry.url)) {
          await launch(entry.url, forceSafariVC: false);
        }
      },
    ));
  }
}
