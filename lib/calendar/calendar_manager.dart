import 'dart:convert';
import 'dart:math';

import 'package:dotlive_schedule/calendar/calendar.dart';
import 'package:dotlive_schedule/common/constants.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CalendarManager with ChangeNotifier {
  static const _calendarCacheKeyPrefix = 'calendar';
  SharedPreferences _sharedPrefs;

  List<CalendarActor> _actors;
  final Map<String, _CalendarCache> _calendarMap =
      Map<String, _CalendarCache>();
  Future<void> _initialize;
  DateTimeJST _currentDate;
  DateTimeJST get currentDate => _currentDate;

  CalendarManager(DateTimeJST _currentDate)
      : this._currentDate =
            DateTimeJST.jst(_currentDate.year, _currentDate.month) {
    _initialize = _init();
    _initialize.then((_) {
      fetchCalendar(this._currentDate, false);
    });
  }

  CalendarResponse getCalendarResponse(DateTimeJST date) {
    final key = _createKey(date);
    final cache = _calendarMap[key];
    if (cache == null) return null;
    return CalendarResponse(cache.toCalendar(), _actors);
  }

  void setCurrentDate(DateTimeJST date) {
    _currentDate = DateTimeJST.jst(date.year, date.month);
    notifyListeners();

    fetchCalendar(_currentDate, false);
  }

  Future<void> fetchCalendar(DateTimeJST date, bool reload) async {
    await _initialize;
    date = DateTimeJST.jst(date.year, date.month);

    final key = _createKey(date);
    _CalendarCache memoryCache = _calendarMap[key];
    if (!reload && memoryCache != null) {
      return;
    }
    memoryCache = memoryCache ?? _CalendarCache.empty(date);

    final storageCache = await _loadStorageCache(date);
    memoryCache = memoryCache.merge(storageCache);

    DateTimeJST queryDate;
    if (memoryCache.fixedDay > 0) {
      queryDate = DateTimeJST.jst(date.year, date.month, memoryCache.fixedDay)
          .add(Duration(days: 1));
    } else {
      queryDate = date;
    }

    String query;
    if (queryDate.month == date.month) {
      query = 'q=$key-${queryDate.day}';
    } else {
      // Actorのみ取得する
      query = 'q=$key-1&t=actor';
    }

    final url = '$baseURL/api/calendar?$query';
    try {
      final res = await http.get(url);
      final calendarRes = CalendarResponse.fromJSON(jsonDecode(res.body));
      _actors = calendarRes.actors;
      final prevFixedDay = memoryCache.fixedDay;
      memoryCache = memoryCache.merge(_CalendarCache(
          date, calendarRes.calendar.fixedDay, calendarRes.calendar.dayMap));

      if (prevFixedDay != memoryCache.fixedDay) {
        await _saveToStorage(memoryCache);
      }
    } catch (_) {
      // todo
      return;
    }

    _calendarMap[key] = memoryCache;
    notifyListeners();
  }

  Future<void> _init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String _createKey(DateTimeJST d) => '${d.year}-${d.month}';
  String _createStorageCacheKey(DateTimeJST d) =>
      '$_calendarCacheKeyPrefix-${d.year}-${d.month}';

  Future<_CalendarCache> _loadStorageCache(DateTimeJST date) async {
    final key = _createStorageCacheKey(date);
    if (_sharedPrefs.containsKey(key)) {
      try {
        final jsonStr = _sharedPrefs.getString(key);
        final cache = _CalendarCache.fromJSON(jsonDecode(jsonStr));
        if (cache.date.year == date.year && cache.date.month == date.month) {
          return cache;
        }
      } catch (e) {
        print(e);
      }

      // エラーが出たor古い場合は消す
      await _sharedPrefs.remove(key);
    }

    return _CalendarCache.empty(date);
  }

  Future<void> _saveToStorage(_CalendarCache cache) async {
    final key = _createStorageCacheKey(cache.date);
    // 確定している日が一日もない場合は削除
    if (cache.fixedDay < 1) {
      await _sharedPrefs.remove(key);
      return;
    }

    await _sharedPrefs.setString(key, cache.toJSON());
  }

  Future<void> clearAll() async {
    await _initialize;

    final keys = _sharedPrefs
        .getKeys()
        .where((k) => k.startsWith(_calendarCacheKeyPrefix))
        .toList();

    for (final key in keys) {
      await _sharedPrefs.remove(key);
    }
    _calendarMap.clear();
    notifyListeners();
  }
}

class _CalendarCache {
  final DateTimeJST date;
  final int fixedDay;
  final CalendarDayMap dayMap;

  _CalendarCache(this.date, this.fixedDay, this.dayMap);

  _CalendarCache.empty(DateTimeJST date)
      : this(date, 0, CalendarDayMap.empty());

  _CalendarCache.fromJSON(Map<String, dynamic> json)
      : date = _parseDate(json['date']),
        fixedDay = json['fixedDay'],
        dayMap = _parseCalendarDayMap(json['dayMap']);

  _CalendarCache merge(_CalendarCache other) {
    final newMap = dayMap.toMap();
    other.dayMap.entries.forEach((e) {
      newMap[e.key] = e.value;
    });

    return _CalendarCache(
        date, max(fixedDay, other.fixedDay), CalendarDayMap(newMap));
  }

  static DateTimeJST _parseDate(String dateStr) {
    final xs = dateStr.split('-');
    if (xs.length != 2) throw Exception('invalid format');
    final year = int.parse(xs[0]);
    final month = int.parse(xs[1]);
    return DateTimeJST.jst(year, month);
  }

  static CalendarDayMap _parseCalendarDayMap(Map<String, dynamic> json) {
    final dayMap = Map<int, List<String>>();
    json.forEach((day, _ids) {
      dayMap[int.parse(day)] = (_ids as List<dynamic>)
          .map((id) => id as String)
          .where((id) => id != null)
          .toList();
    });

    return CalendarDayMap(dayMap);
  }

  Calendar toCalendar() => Calendar(date, dayMap, fixedDay);

  String toJSON() {
    final inner = dayMap.entries.where((e) => e.key <= fixedDay).map((e) {
      final values = e.value.map((s) => '"$s"').join(',');
      return '"${e.key}":[$values]';
    }).join(',');

    return '{"date":"${date.year}-${date.month}","dayMap":{$inner},"fixedDay":$fixedDay}';
  }
}
