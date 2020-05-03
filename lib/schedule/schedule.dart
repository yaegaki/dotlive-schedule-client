import 'package:dotlive_schedule/common/datetime_jst.dart';

class Schedule {
  final DateTimeJST date;
  final List<ScheduleEntry> entries;
  final bool hasError;

  Schedule(this.date, this.entries) : hasError = false;

  Schedule.error()
      : date = null,
        entries = null,
        hasError = true;

  Schedule.fromJSON(Map<String, dynamic> json)
      : date = DateTimeJST.parse(json['date']),
        entries = toEntries(json['entries']),
        hasError = false;

  static List<ScheduleEntry> toEntries(List<dynamic> entries) {
    return entries.map((e) => ScheduleEntry.fromJSON(e)).toList();
  }
}

class ScheduleEntry {
  final String actorName;
  final String icon;
  final DateTimeJST startAt;
  final String videoId;
  final String url;
  final bool planned;
  final bool isLive;
  final String text;

  ScheduleEntry(this.actorName, this.icon, this.startAt, this.videoId, this.url,
      this.planned, this.isLive, this.text);

  ScheduleEntry.fromJSON(Map<String, dynamic> json)
      : actorName = json['actorName'],
        icon = json['icon'],
        startAt = DateTimeJST.parse(json['startAt']),
        videoId = json['videoId'],
        url = json['url'],
        planned = json['planned'],
        isLive = json['isLive'],
        text = json['text'];
}
