import 'dart:convert';

import 'package:dotlive_schedule/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ScheduleList extends StatefulWidget {
  final DateTime date;

  ScheduleList(this.date);

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  Schedule _schedule;
  int _version = 0;

  @override
  void initState() {
    super.initState();

    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    final jst = widget.date.add(Duration(hours: 9));
    final url =
        'https://dotlive-schedule.appspot.com?q=${jst.year}-${jst.month}-${jst.day}';
    _version += 1;
    final temp = _version;
    final res = await http.get(url);
    if (!mounted) return;
    if (temp != _version) return;

    setState(() {
      _schedule = Schedule.fromJSON(jsonDecode(res.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_schedule == null) {
      return Center(child: CircularProgressIndicator());
    }

    int itemCount;
    Function(BuildContext, int) itemBuilder;
    if (_schedule.entries.length == 0) {
      itemCount = 1;
      itemBuilder = (_, __) {
        return Card(
            child: ListTile(
          title: Text('予定がありません'),
        ));
      };
    } else {
      itemCount = _schedule.entries.length;
      itemBuilder = (_, index) => _createCard(_schedule.entries[index]);
    }

    return RefreshIndicator(
      onRefresh: () => fetchSchedule(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
    );
  }

  Widget _createCard(ScheduleEntry entry) {
    final d = entry.startAt.add(Duration(hours: 9));
    final title =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}~ ${entry.actorName}';
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
