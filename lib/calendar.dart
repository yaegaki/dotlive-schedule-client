import 'datetime_jst.dart';

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
  final List<CalendarDay> days;

  Calendar.fromJSON(Map<String, dynamic> json)
      : baseDate = DateTimeJST.parse(json['baseDate']),
        days = _toDays(json['days']);

  static List<CalendarDay> _toDays(List<dynamic> days) {
    return days.map((d) => CalendarDay.fromJSON(d)).toList();
  }
}

class CalendarDay {
  final int day;
  final List<CalendarDayEntry> entries;

  CalendarDay.fromJSON(Map<String, dynamic> json)
      : day = json['day'],
        entries = _toEntries(json['entries']);

  static List<CalendarDayEntry> _toEntries(List<dynamic> entries) {
    return entries.map((e) => CalendarDayEntry.fromJSON(e)).toList();
  }
}

class CalendarDayEntry {
  final String actorId;
  final String text;
  final String url;

  CalendarDayEntry.fromJSON(Map<String, dynamic> json)
      : actorId = json['actorId'],
        text = json['text'],
        url = json['url'];
}
