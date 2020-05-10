import 'package:dotlive_schedule/messaging/messaging_manager.dart';
import 'package:dotlive_schedule/messaging/topic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SettingsNotificationPage extends StatefulWidget {
  @override
  _SettingsNotificationPageState createState() =>
      _SettingsNotificationPageState();
}

class _SettingsNotificationPageState extends State<SettingsNotificationPage> {
  Topic _planTopic;
  List<Topic> _actorTopics;
  bool _hasError = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    final manager = Provider.of<MessagingManager>(context, listen: false);
    _getTopics(manager);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('通知設定')),
      body: Consumer<MessagingManager>(builder: (context, manager, _) {
        return _buildBody(context, manager);
      }),
    );
  }

  Widget _buildBody(BuildContext context, MessagingManager manager) {
    if (_hasError) {
      final themeData = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('通信エラー', style: themeData.textTheme.headline6),
            Text('通信環境の良い場所でリトライしてください', style: themeData.textTheme.bodyText1),
            RaisedButton(
                onPressed: () => _getTopics(manager), child: Text('リトライ')),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    if (!manager.hasPermissions) {
      final themeData = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('通知設定が無効になっています', style: themeData.textTheme.headline6),
            Text('設定から通知設定を有効にしてリトライしてください',
                style: themeData.textTheme.bodyText1),
            RaisedButton(
                onPressed: () => _getTopics(manager), child: Text('リトライ')),
          ],
        ),
      );
    }

    return ListView(padding: MediaQuery.of(context).padding, children: <Widget>[
      _buildPlanTile(context, manager),
      _buildActorsTile(context, manager),
    ]);
  }

  Future<void> _getTopics(MessagingManager manager) async {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });

    try {
      await manager.requestNotificationPermissions();
      if (!manager.hasPermissions) {
        setState(() {
          _isInitialized = true;
        });
        return;
      }

      final topics = await manager.getTopics();
      setState(() {
        _actorTopics = <Topic>[];

        topics.forEach((t) {
          if (t.name == 'plan') {
            _planTopic = t;
          } else {
            _actorTopics.add(t);
          }
        });

        _isInitialized = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        _hasError = true;
      });
    }
  }

  Widget _buildPlanTile(BuildContext context, MessagingManager manager) {
    return Card(
        child: ListTile(
      title: Text('スケジュール', style: Theme.of(context).textTheme.headline6),
      trailing: Switch(
          onChanged: (v) {
            subscribeOrUnsubscribeTopic(context, manager, _planTopic);
          },
          value: _planTopic.subscribed),
      subtitle: Text('翌日のスケジュールが通知されます'),
      isThreeLine: true,
    ));
  }

  Widget _buildActorsTile(BuildContext context, MessagingManager manager) {
    final children = <Widget>[
      ListTile(
        title: Text('配信', style: Theme.of(context).textTheme.headline6),
        subtitle: Text('動画の投稿及びライブの開始時に通知されます'),
        isThreeLine: true,
      )
    ];

    _actorTopics.forEach((t) {
      children.add(ListTile(
        title:
            Text(t.displayName, style: Theme.of(context).textTheme.headline6),
        trailing: Switch(
            onChanged: (v) {
              subscribeOrUnsubscribeTopic(context, manager, t);
            },
            value: t.subscribed),
      ));
    });

    return Card(child: Column(children: children));
  }

  Future<void> subscribeOrUnsubscribeTopic(
      BuildContext context, MessagingManager manager, Topic topic) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            title: Text('通信中'),
            children: <Widget>[
              Center(child: CircularProgressIndicator()),
            ],
          );
        });

    var completed = false;
    try {
      if (topic.subscribed) {
        await manager.unsubscribeTopic(topic.name);
      } else {
        await manager.subscribeTopic(topic.name);
      }

      setState(() {
        final newTopic =
            Topic(topic.name, topic.displayName, !topic.subscribed);
        if (topic.name == 'plan') {
          _planTopic = newTopic;
        } else {
          for (var i = 0; i < _actorTopics.length; i++) {
            if (_actorTopics[i].name == newTopic.name) {
              _actorTopics[i] = newTopic;
              break;
            }
          }
        }
      });
      completed = true;
    } catch (e) {}

    Navigator.pop(context);

    if (!completed) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('エラー'),
              content: Text('設定中にエラーが発生しました\n通信環境の良い場所でリトライしてください'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          });
    }
  }
}
