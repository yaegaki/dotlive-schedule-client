import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/widgets/calendar/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  PageController _pageController;
  CalendarManager _manager;
  int _currentPage;

  @override
  void initState() {
    super.initState();
    _manager = Provider.of<CalendarManager>(context, listen: false);
    _currentPage = _calcIndexFromDate(_manager.currentDate);
    _pageController = PageController(
      initialPage: _currentPage,
    );

    _manager.fetchCalendar(_manager.currentDate, false);
    _manager.addListener(_managerListener);
  }

  @override
  dispose() {
    super.dispose();
    _pageController.dispose();
    _manager.removeListener(_managerListener);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          return Consumer<CalendarManager>(builder: (context, manager, _) {
            final date = _calcDateFromIndex(index);
            final calendarRes = manager.getCalendarResponse(date);
            if (calendarRes == null) {
              return Center(child: CircularProgressIndicator());
            }

            return LayoutBuilder(builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () =>
                    manager.fetchCalendar(manager.currentDate, true),
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: CalendarView(
                          calendarRes.calendar, calendarRes.actors),
                    )),
              );
            });
          });
        },
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
            _manager.setCurrentDate(_calcDateFromIndex(index));
          });
        });
  }

  DateTimeJST _calcDateFromIndex(int index) {
    var date = DateTimeJST.fromYM(CalendarManager.calendarBeginDate);
    for (var i = 0; i < index; i++) {
      date = DateTimeJST.fromYM(date.add(const Duration(days: 32)));
    }
    return date;
  }

  int _calcIndexFromDate(DateTimeJST d) {
    return d.differenceMonth(CalendarManager.calendarBeginDate);
  }

  void _managerListener() {
    if (_pageController == null || !_pageController.hasClients) {
      return;
    }

    final targetPage = _calcIndexFromDate(_manager.currentDate);
    if (_currentPage == targetPage) return;

    setState(() {
      _pageController.jumpToPage(targetPage >= 0 ? targetPage : 0);
    });
  }
}
