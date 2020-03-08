class Schedule {
  final DateTime date;
  final List<ScheduleEntry> entries;

  Schedule(this.date, this.entries);

  Schedule.fromJSON(Map<String, dynamic> json)
    : date = DateTime.parse(json['date']),
      entries = toEntries(json['entries']);

  static List<ScheduleEntry> toEntries(List<dynamic> entries) {
    return entries.map((e) => ScheduleEntry.fromJSON(e)).toList();
  }
}

class ScheduleEntry {
  final String actorName;
  final String icon;
  final DateTime startAt;
  final String videoId;
  final String url;
  final bool planned;
  final bool isLive;
  final String text;

  ScheduleEntry(this.actorName, this.icon, this.startAt, this.videoId, this.url, this.planned, this.isLive, this.text);

  ScheduleEntry.fromJSON(Map<String, dynamic> json)
    : actorName = json['actorName'],
      icon = json['icon'],
      startAt = DateTime.parse(json['startAt']),
      videoId = json['videoId'],
      url = json['url'],
      planned = json['planned'],
      isLive = json['isLive'],
      text = json['text'];
}
