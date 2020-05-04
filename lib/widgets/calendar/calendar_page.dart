import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_filter_option.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_view.dart';
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
        return Center(child: CircularProgressIndicator());
      }

      final filterOption = Provider.of<CalendarFilterOption>(context);
      Future(() {
        if (filterOption.enabled) return;
        filterOption.setActors(calendarRes.actors);
      });

      return LayoutBuilder(builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () => manager.fetchCalendar(manager.currentDate, true),
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: CalendarView(calendarRes.calendar, calendarRes.actors),
              )),
        );
      });
    });
  }
}
