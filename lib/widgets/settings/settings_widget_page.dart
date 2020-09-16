import 'package:dotlive_schedule/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsWidgetPage extends StatelessWidget {
  static const platform =
      const MethodChannel('jp.yaegaki.dotlive-schedule/widget');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ウィジェット')),
      body: ListView(
        padding: MediaQuery.of(context).padding,
        children: <Widget>[
          Card(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('ウィジェットについて',
                    style: Theme.of(context).textTheme.headline6),
                subtitle: Text('''このアプリにはどっとライブ予定表ウィジェットが付属しています。
このウィジェットは竜崎あわい先生(@awaiflavia)の最新のどっとライブ予定表を表示するものです。
アプリを立ち上げることなくホーム画面及びロック画面から素早くどっとライブ予定表を確認することができます。'''),
              ),
              Image.network(
                  'https://dotlive-schedule.appspot.com/ss-widget2.png'),
            ],
          )),
          Card(
            child: ListTile(
              title: Text("竜崎あわい先生のアカウント",
                  style: Theme.of(context).textTheme.headline6),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                launch('https://twitter.com/awaiflavia');
              },
            ),
          ),
          Card(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('ウィジェットの更新',
                    style: Theme.of(context).textTheme.headline6),
                subtitle:
                    Text('ウィジェットを強制的に更新します。\nデータが読み込めない場合や表示がおかしい場合にお試しください。'),
              ),
              RaisedButton(
                  child: Text('更新'),
                  onPressed: () {
                    _forceUpdateWidgets(context);
                  }),
            ],
          )),
          Card(
            child: ListTile(
              leading: Icon(Icons.help),
              title: Text("ウィジェットとは",
                  style: Theme.of(context).textTheme.headline6),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                launch('$baseURL/help#widget');
              },
            ),
          ),
        ],
      ),
    );
  }

  _forceUpdateWidgets(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            title: Text('更新中'),
            children: <Widget>[
              Center(child: CircularProgressIndicator()),
            ],
          );
        });

    try {
      await platform.invokeMethod('forceUpdateWidgets');
    } catch (e) {}

    Navigator.pop(context);

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('完了'),
            content: Text('更新が完了しました'),
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
