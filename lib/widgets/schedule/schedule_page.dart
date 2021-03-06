import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/schedule/schedule_manager.dart';
import 'package:dotlive_schedule/widgets/schedule/schedule_list.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SchedulePage extends StatefulWidget {
  final DateTimeJST _baseDate;
  final bool canControl;

  SchedulePage(this._baseDate, {this.canControl = true});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // 何日前までさかのぼれるか
  static final _prevDayLimit = 6;
  ScheduleManager _manager;
  DateTimeJST _currentDate;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _manager = Provider.of<ScheduleManager>(context, listen: false);
    _manager.addListener(_managerListener);
    _currentDate = _manager.currentDate;
    if (!widget.canControl) {
      _manager.fetchSchedule(widget._baseDate, true);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _pageController?.dispose();
    _manager.removeListener(_managerListener);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canControl) {
      return ScheduleList(widget._baseDate, canControl: false);
    }

    final _baseDate = widget._baseDate;
    if (_pageController == null || !_pageController.hasClients) {
      final page = _manager.currentDate.differenceDay(
          widget._baseDate.subtract(Duration(days: _prevDayLimit)));
      _pageController = PageController(initialPage: page >= 0 ? page : 0);
    }

    return PageView.builder(
      controller: _pageController,
      itemBuilder: (_, index) {
        final date = _baseDate.add(Duration(days: index - _prevDayLimit));
        return ScheduleList(date);
      },
      onPageChanged: (index) {
        final date = _baseDate.add(Duration(days: index - _prevDayLimit));
        setState(() {
          _currentDate = date;
          _manager.setCurrentDate(date);
        });
      },
    );
  }

  void _managerListener() {
    if (_pageController == null || !_pageController.hasClients) {
      return;
    }

    if (_currentDate.differenceDay(_manager.currentDate) == 0) {
      return;
    }

    final page = _manager.currentDate.differenceDay(
        widget._baseDate.subtract(Duration(days: _prevDayLimit)));
    setState(() {
      _currentDate = _manager.currentDate;
      _pageController.jumpToPage(page >= 0 ? page : 0);
    });
  }
}
