import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SortOption with ChangeNotifier {
  static const _sortByAscKey = "sortByAsc";
  SharedPreferences _sharedPrefs;

  bool _asc = true;
  bool get asc => _asc;

  SortOption() {
    _init();
  }

  void update(bool asc) {
    _update(asc, true);
  }

  void _update(bool asc, bool saveToPrefs) {
    _asc = asc;
    if (saveToPrefs && _sharedPrefs != null) {
      _sharedPrefs.setBool(_sortByAscKey, asc);
    }

    notifyListeners();
  }

  void _init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    var sortByAsc = true;
    if (_sharedPrefs.containsKey(_sortByAscKey)) {
      sortByAsc = _sharedPrefs.getBool(_sortByAscKey);
    }
    _update(sortByAsc, false);
  }
}