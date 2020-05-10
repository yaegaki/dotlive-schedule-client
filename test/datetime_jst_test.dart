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

    test('before', () {
      final t1 = DateTimeJST.jst(2020, 4, 1, 0, 0);
      final t2 = DateTimeJST.jst(2020, 4, 1, 23, 59);
      final t3 = DateTimeJST.jst(2020, 4, 2, 0, 0);
      expect(t1.before(t2), true);
      expect(t1.before(t3), true);
      expect(t2.before(t3), true);
      expect(t3.before(t1), false);
      expect(t3.before(t2), false);
      expect(t3.before(t3), false);
    });

    test("differenceDay", () {
      final t1 = DateTimeJST.jst(2020, 4, 1, 0, 0);
      final t2 = DateTimeJST.jst(2020, 4, 1, 23, 59);
      final t3 = DateTimeJST.jst(2020, 4, 2, 0, 0);
      expect(t2.differenceDay(t1), 0);
      expect(t3.differenceDay(t2), 1);
    });

    test("differenceMonth", () {
      final t1 = DateTimeJST.jst(2020, 4, 1, 0, 0);
      final t2 = DateTimeJST.jst(2020, 4, 1, 23, 59);
      final t3 = DateTimeJST.jst(2020, 4, 2, 0, 0);
      final t4 = DateTimeJST.jst(2020, 4, 30, 0, 0);
      final t5 = DateTimeJST.jst(2020, 5, 1, 0, 0);
      expect(t1.differenceMonth(t1), 0);
      expect(t2.differenceMonth(t1), 0);
      expect(t3.differenceMonth(t2), 0);
      expect(t4.differenceMonth(t1), 0);
      expect(t5.differenceMonth(t1), 1);
      expect(t5.differenceMonth(t4), 1);
      expect(t1.differenceMonth(t5), -1);
    });

    test("weekday", () {
      final t1 = DateTimeJST.jst(2020, 5, 1);
      // DateTime.friday == 5
      expect(t1.weekday, DateTime.friday);
    });
  });
}
