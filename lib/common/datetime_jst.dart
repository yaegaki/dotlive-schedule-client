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

  DateTimeJST.fromYM(DateTimeJST d) : this.jst(d.year, d.month);

  DateTimeJST.jst(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : _date = DateTime.utc(year, month, day, hour, minute, second, millisecond);

  DateTimeJST.now() : this(DateTime.now());
  DateTimeJST.parse(string) : this(DateTime.parse(string));

  DateTimeJST add(Duration d) => DateTimeJST(utc.add(d));
  DateTimeJST subtract(Duration d) => DateTimeJST(utc.subtract(d));
  Duration difference(DateTimeJST d) => _date.difference(d._date);

  bool before(DateTimeJST d) => difference(d).isNegative;

  // 指定した時間と何日違うかを返す
  // 1時間しか差がなくても日付が違う場合は1を返す
  int differenceDay(DateTimeJST d) {
    // 日付未満を切り捨てて差分をとる
    final self = DateTime.utc(year, month, day);
    final other = DateTime.utc(d.year, d.month, d.day);
    return self.difference(other).inDays;
  }

  int differenceMonth(DateTimeJST d) {
    final b = before(d);
    var start = DateTimeJST.fromYM(b ? this : d);
    final end = DateTimeJST.fromYM(b ? d : this);

    var index = 0;
    const month = Duration(days: 32);
    for (; start.before(end); index++) {
      start = DateTimeJST.fromYM(start.add(month));
    }

    return b ? -index : index;
  }
}