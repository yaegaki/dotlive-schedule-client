import 'dart:convert';
import 'dart:math';

import 'package:dotlive_schedule/common/constants.dart';
import 'package:dotlive_schedule/common/datetime_jst.dart';
import 'package:dotlive_schedule/messaging/topic.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class MessagingManager extends ChangeNotifier {
  bool _hasPermissions;
  bool get hasPermissions => _hasPermissions;

  String _token;
  String get token => _token;

  final Random _rand = Random();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  Message _lastReceivedMessage;
  Message get lastReceivedMessage => _lastReceivedMessage;

  Future<void> init() async {
    await requestNotificationPermissions();

    await _flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
          AndroidInitializationSettings('ic_notification'),
          IOSInitializationSettings(),
        ), onSelectNotification: (s) {
      _lastReceivedMessage = Message(s);
      notifyListeners();
      return null;
    });

    _firebaseMessaging.onTokenRefresh.listen((token) {
      _token = token;
      notifyListeners();
    });

    _firebaseMessaging.configure(
      onLaunch: (msg) => _onMessage(msg, true),
      onResume: (msg) => _onMessage(msg, true),
      onMessage: (msg) => _onMessage(msg, false),
    );
  }

  Future<void> requestNotificationPermissions() async {
    _hasPermissions = await _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    if (_hasPermissions == null) _hasPermissions = true;
    // パーミッションに関わらずトークンは取得できる
    _token = await _firebaseMessaging.getToken();
    notifyListeners();
  }

  Future<List<Topic>> getTopics() async {
    final res = await http.post('$baseURL/api/topic', body: {
      't': _token,
    });

    return (jsonDecode(res.body) as List<dynamic>)
        .map((json) => Topic.fromJSON(json))
        .toList();
  }

  Future<void> subscribeTopic(String topicName) async {
    await _firebaseMessaging.subscribeToTopic(topicName);
  }

  Future<void> unsubscribeTopic(String topicName) async {
    await _firebaseMessaging.unsubscribeFromTopic(topicName);
  }

  Future<void> subscribeAllTopic() async {
    final topics = await getTopics();
    for (final topic in topics) {
      if (topic.subscribed) {
        continue;
      }
      // subscribeToTopicは並列にやっても直列にやっても速度が変わらない
      await _firebaseMessaging
          .subscribeToTopic(topic.name)
          .timeout(Duration(seconds: 10));
    }
  }

  DateTimeJST getDateFromLastReceivedMessage() {
    final data = _lastReceivedMessage?.data;
    if (data == null) return null;

    final xs = data.split('-');
    if (xs.length != 3) return null;
    final year = int.tryParse(xs[0]);
    final month = int.tryParse(xs[1]);
    final day = int.tryParse(xs[2]);
    if (year == null || month == null || day == null) return null;
    return DateTimeJST.jst(year, month, day);
  }

  Future<void> _onMessage(Map<String, dynamic> msg, bool silent) async {
    String title, body, payload;

    final notification = msg['notification'] as Map<dynamic, dynamic>;
    if (notification != null) {
      title = notification['title'];
      body = notification['body'];

      final data = msg['data'] as Map<dynamic, dynamic>;
      if (data == null) return;
      payload = data['date'];
    } else {
      final aps = msg['aps'] as Map<dynamic, dynamic>;
      if (aps == null) return;
      final alert = aps['alert'] as Map<dynamic, dynamic>;
      if (alert == null) return;

      title = alert['title'];
      body = alert['body'];
      payload = msg['date'];
    }

    if (title == null || body == null || payload == null) return;

    if (silent) {
      _lastReceivedMessage = Message(payload);
      notifyListeners();
      return;
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'fcm_fallback_notification_channel', '通知', '通知');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    final id = DateTime.now().toString().hashCode + _rand.nextInt(10000);
    await _flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }
}

class Message {
  final String data;
  Message(this.data);
}
