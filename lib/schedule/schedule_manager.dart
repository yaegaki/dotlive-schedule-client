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
  MessagingManager _messagingManager;
  DateTimeJST _currentDate;
  DateTimeJST get currentDate => _currentDate;
  Message _lastReceivedMessage;

  ScheduleManager(this._messagingManager, this._currentDate) {
    _currentDate = _getDateFromMessagingManager() ?? _currentDate;
    fetchSchedule(_currentDate, false);
    _messagingManager.addListener(_onMessagingManagerChanged);
  }

  void setCurrentDate(DateTimeJST date) {
    _currentDate = date;
    notifyListeners();

    fetchSchedule(date, false);
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

  DateTimeJST _getDateFromMessagingManager() {
    _lastReceivedMessage = _messagingManager.lastReceivedMessage;
    final data = _lastReceivedMessage?.data;
    if (data == null) return null;

    final xs = data.split('-');
    if (xs.length != 3) return null;
    final year = int.tryParse(xs[0]);
    final month = int.tryParse(xs[1]);
    final day = int.tryParse(xs[2]);
    if (year == null || month == null || day == null) return null;
    return DateTimeJST.jst(year, month, day);
  }

  void _onMessagingManagerChanged() {
    if (_lastReceivedMessage == _messagingManager.lastReceivedMessage) {
      return;
    }

    final date = _getDateFromMessagingManager();
    if (date == null) return;
    setCurrentDate(date);
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