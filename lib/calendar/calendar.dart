import 'package:dotlive_schedule/common/datetime_jst.dart';

class CalendarResponse {
  final Calendar calendar;
  final List<CalendarActor> actors;

  CalendarResponse.fromJSON(Map<String, dynamic> json)
      : calendar = Calendar.fromJSON(json['calendar']),
        actors = _toActors(json['actors']);

  static List<CalendarActor> _toActors(List<dynamic> actors) {
    return actors.map((a) => CalendarActor.fromJSON(a)).toList();
  }
}

class CalendarActor {
  final String id;
  final String name;
  final String icon;
  final String emoji;

  CalendarActor.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        icon = json['icon'],
        emoji = json['emoji'];
}

class Calendar {
  final DateTimeJST baseDate;
  final Map<int, List<String>> dayMap;

  Calendar.fromJSON(Map<String, dynamic> json)
      : baseDate = DateTimeJST.parse(json['baseDate']),
        dayMap = _toDayMap(json['days']);

  static Map<int, List<String>> _toDayMap(List<dynamic> days) {
    final map = new Map<int, List<String>>();
    days.map((d) => _CalendarDay.fromJSON(d)).forEach((d) {
      map[d.day] = d.actorIds;
    });

    return map;
  }
}

class _CalendarDay {
  final int day;
  final List<String> actorIds;

  _CalendarDay.fromJSON(Map<String, dynamic> json)
      : day = json['day'],
        actorIds = _toActorIds(json['actorIds']);

  static List<String> _toActorIds(List<dynamic> entries) {
    return entries.map((e) => e as String).toList();
  }
}
