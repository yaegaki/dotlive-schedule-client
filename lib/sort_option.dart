import 'package:flutter/widgets.dart';

class SortOption with ChangeNotifier {
  bool _asc = true;
  bool get asc => _asc;

  void update(bool asc) {
    _asc = asc;
    notifyListeners();
  }
}