import 'dart:convert';

import 'package:dotlive_schedule/common/constants.dart';
import 'package:dotlive_schedule/messaging/topic.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class MessagingManager extends ChangeNotifier {
  bool _hasPermissions;
  bool get hasPermissions => _hasPermissions;

  String _token;
  String get token => _token;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<void> init() async {
    _hasPermissions = await _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    if (_hasPermissions == null) _hasPermissions = true;
    if (_hasPermissions) {
      _token = await _firebaseMessaging.getToken();
    }

    _firebaseMessaging.onTokenRefresh.listen((token) {
      _token = token;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> subscribeAllTopic() async {
    if (!_hasPermissions) {
      throw Exception('does not have permissions');
    }

    final res = await http.post('$baseURL/api/topic', body: {
      't': _token,
    });

    final futures = (jsonDecode(res.body) as List<dynamic>)
        .map((json) => Topic.fromJSON(json))
        // .map((t) {
        //   print('${t.displayName}:${t.name}:${t.subscribed}');
        //   return t;
        // })
        .where((t) => !t.subscribed)
        .map((t) => _firebaseMessaging.subscribeToTopic(t.name));

    await Future.wait(futures);
  }
}
