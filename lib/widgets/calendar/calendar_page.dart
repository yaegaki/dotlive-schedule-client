import 'dart:convert';

import 'package:dotlive_schedule/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class CalendarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarResponse calendarRes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text("calendar");
  }
}
