import 'dart:convert';

import 'package:dotlive_schedule/datetime_jst.dart';
import 'package:dotlive_schedule/schedule.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ScheduleManager with ChangeNotifier {
  final Map<String, _ScheduleManagerCacheEntry> _scheduleMap = Map<String, _ScheduleManagerCacheEntry>();
  int _version = 0;
  DateTimeJST _currentDate;
  DateTimeJST get currentDate => _currentDate;

  ScheduleManager(this._currentDate) {
    fetchSchedule(this._currentDate, false);
  }

  void setCurrentDate(DateTimeJST date) {
    _currentDate = date;
    notifyListeners();

    fetchSchedule(date, false);
  }

  Schedule getSchedule(DateTimeJST date) {
    final key = createKey(date);
    if (!_scheduleMap.containsKey(key)) return null;
    return _scheduleMap[key].schedule;
  }

  Future<void> fetchSchedule(DateTimeJST date, bool reload) async {
    final key = createKey(date);
    if (!reload && _scheduleMap.containsKey(key)) {
      return;
    }

    _version += 1;
    final v = _version;

    final url = 'https://dotlive-schedule.appspot.com/api/schedule?q=$key';
    Schedule schedule;
    try {
      final res = await http.get(url);
      schedule = Schedule.fromJSON(jsonDecode(res.body));
    } catch (_) {
      schedule = Schedule.error();
    }

    if (_scheduleMap.containsKey(key)) {
      final c = _scheduleMap[key];
      if (c.version > v) {
        return;
      }
    }

    _scheduleMap[key] = _ScheduleManagerCacheEntry(v, schedule);
    notifyListeners();
  }

  String createKey(DateTimeJST d) => '${d.year}-${d.month}-${d.day}';
}

class _ScheduleManagerCacheEntry {
  final int version;
  final Schedule schedule;
  _ScheduleManagerCacheEntry(this.version, this.schedule);
}