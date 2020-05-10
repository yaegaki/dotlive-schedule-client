import 'package:dotlive_schedule/messaging/messaging_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitializer extends ChangeNotifier {
  static final String _currentVersion = '1.0.0';
  static final String _versionKey = 'version';

  SharedPreferences _sharedPrefs;

  MessagingManager _messagingManager = MessagingManager();
  MessagingManager get messagingManager => _messagingManager;

  bool _initializeFailed = false;
  bool get initializeFailed => _initializeFailed;

  bool _initialized = false;
  bool get initialized => _initialized;

  AppInitializer() {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      messagingManager.init(),
      (() async {
        _sharedPrefs = await SharedPreferences.getInstance();
      })(),
    ]);

    await reinit();
  }

  Future<void> reinit() async {
    _initializeFailed = false;
    notifyListeners();

    try {
      final version = _sharedPrefs.getString(_versionKey);
      if (version == null) {
        if (messagingManager.hasPermissions) {
          // 初回起動時はトピックを全て購読する
          await _messagingManager.subscribeAllTopic();
        }
      } else if (version != _currentVersion) {
        // todo: 新機能の告知など
      }

      if (version != _currentVersion) {
        await _sharedPrefs.setString(_versionKey, _currentVersion);
      }
      _initialized = true;
    } catch (_) {
      _initializeFailed = true;
    }

    notifyListeners();
  }
}
