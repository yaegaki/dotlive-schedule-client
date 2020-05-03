import 'package:dotlive_schedule/calendar/calendar.dart';
import 'package:flutter/widgets.dart';

class CalendarFilterOption with ChangeNotifier {
  bool get enabled => _actors != null;

  Set<String> _filters = new Set<String>();
  Set<String> get filters => _filters;
  Set<CalendarActor> _actors;
  Set<CalendarActor> get actors => _actors;

  void setActors(Iterable<CalendarActor> actors) {
    this._actors = actors.toSet();
    notifyListeners();
  }

  void update(Iterable<String> filters) {
    this._filters = filters.toSet();
    notifyListeners();
  }
}
