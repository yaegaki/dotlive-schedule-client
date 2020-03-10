class DateTimeJST {
  static final Duration timezoneOffset = const Duration(hours: 9);
  final DateTime _date;
  DateTime get utc => _date.subtract(timezoneOffset);

  int get year => _date.year;
  int get month => _date.month;
  int get day => _date.day;
  int get weekday => _date.weekday;
  int get hour => _date.hour;
  int get minute => _date.minute;

  DateTimeJST(DateTime d) : _date = d.toUtc().add(timezoneOffset);

  DateTimeJST.now() : this(DateTime.now());
  DateTimeJST.parse(string) : this(DateTime.parse(string));

  DateTimeJST add(Duration d) => DateTimeJST(utc.add(d));
  DateTimeJST subtract(Duration d) => DateTimeJST(utc.subtract(d));
  Duration difference(DateTimeJST d) => _date.difference(d._date);

  // 指定した時間と何日違うかを返す
  // 1時間しか差がなくても日付が違う場合は1を返す
  differenceDay(DateTimeJST d) {
    final self = DateTime.utc(year, month, day);
    final other = DateTime.utc(d.year, d.month, d.day);
    return DateTimeJST(self).difference(DateTimeJST(other)).inDays;
  }
}