import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/widgets/schedule/schedule_app_bar.dart';
import 'package:dotlive_schedule/widgets/schedule/schedule_page.dart';
import 'package:flutter/material.dart';

class CalendarSchedulePage extends StatelessWidget {
  final DateTimeJST targetDate;

  CalendarSchedulePage(this.targetDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ScheduleAppBar(targetDate: targetDate),
        body: SchedulePage(targetDate, canControl: false),
      );
  }
}
