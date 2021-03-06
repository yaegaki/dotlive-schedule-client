import 'dart:convert';

import 'package:dotlive_schedule/common/constants.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/messaging/messaging_manager.dart';
import 'package:dotlive_schedule/schedule/schedule.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ScheduleManager with ChangeNotifier {
  final Map<String, _ScheduleManagerCacheEntry> _scheduleMap = Map<String, _ScheduleManagerCacheEntry>();
  int _version = 0;
  final MessagingManager _messagingManager;
  DateTimeJST _currentDate;
  DateTimeJST get currentDate => _currentDate;
  Message _lastReceivedMessage;

  ScheduleManager(this._messagingManager, this._currentDate) {
    _currentDate = _messagingManager.getDateFromLastReceivedMessage() ?? _currentDate;
    fetchSchedule(_currentDate, false);
    _messagingManager.addListener(_onMessagingManagerChanged);
  }

  void setCurrentDate(DateTimeJST date, { bool reload = false }) {
    _currentDate = date;
    notifyListeners();

    fetchSchedule(date, reload);
  }

  Schedule getSchedule(DateTimeJST date) {
    final key = _createKey(date);
    if (!_scheduleMap.containsKey(key)) return null;
    return _scheduleMap[key].schedule;
  }

  Future<void> fetchSchedule(DateTimeJST date, bool reload) async {
    final key = _createKey(date);
    if (!reload && _scheduleMap.containsKey(key)) {
      return;
    }

    _version += 1;
    final v = _version;

    final url = '$baseURL/api/schedule?q=$key';
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

  String _createKey(DateTimeJST d) => '${d.year}-${d.month}-${d.day}';

  void _onMessagingManagerChanged() {
    if (_lastReceivedMessage == _messagingManager.lastReceivedMessage) {
      return;
    }

    final date = _messagingManager.getDateFromLastReceivedMessage();
    if (date == null) return;
    setCurrentDate(date, reload: true);
  }

  @override
  void dispose() {
    super.dispose();

    _messagingManager.removeListener(_onMessagingManagerChanged);
  }
}

class _ScheduleManagerCacheEntry {
  final int version;
  final Schedule schedule;
  _ScheduleManagerCacheEntry(this.version, this.schedule);
}