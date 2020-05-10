import 'package:dotlive_schedule/messaging/messaging_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitializer extends ChangeNotifier {
  static final String _versionKey = 'version';

  SharedPreferences _sharedPrefs;

  PackageInfo _packageInfo;
  PackageInfo get packageInfo => _packageInfo;

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
      (() async {
        _packageInfo = await PackageInfo.fromPlatform();
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
      } else if (version != _packageInfo.version) {
        // todo: 新機能の告知など
      }

      if (version != _packageInfo.version) {
        await _sharedPrefs.setString(_versionKey, _packageInfo.version);
      }
      _initialized = true;
    } catch (_) {
      _initializeFailed = true;
    }

    notifyListeners();
  }
}
