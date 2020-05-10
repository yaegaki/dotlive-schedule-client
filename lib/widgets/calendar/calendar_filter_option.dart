import 'package:flutter/widgets.dart';

class CalendarFilterOption with ChangeNotifier {
  Set<String> _filters = new Set<String>();
  Set<String> get filters => _filters;

  void update(Iterable<String> filters) {
    this._filters = filters.toSet();
    notifyListeners();
  }
}
