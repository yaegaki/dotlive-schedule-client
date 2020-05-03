import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("DateTimeJST", () {
    test("jst", () {
      final t1 = DateTimeJST.jst(2020, 4, 1, 23, 59);
      expect(t1.year, 2020);
      expect(t1.month, 4);
      expect(t1.day, 1);
    });

    test("differenceDay", () {
      final t1 = DateTimeJST.jst(2020, 4, 1, 0, 0);
      final t2 = DateTimeJST.jst(2020, 4, 1, 23, 59);
      final t3 = DateTimeJST.jst(2020, 4, 2, 0, 0);
      expect(t2.differenceDay(t1), 0);
      expect(t3.differenceDay(t2), 1);
    });

    test("weekday", () {
      final t1 = DateTimeJST.jst(2020, 5, 1);
      // DateTime.friday == 5
      expect(t1.weekday, DateTime.friday);
    });
  });
}
