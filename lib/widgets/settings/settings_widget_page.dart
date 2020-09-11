import 'package:dotlive_schedule/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsWidgetPage extends StatelessWidget {
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
              leading: Icon(Icons.help),
              title: Text("ウィジェットとは",
                  style: Theme.of(context).textTheme.headline6),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                launch('$baseURL/help#widget');
              },
            ),
          )
        ],
      ),
    );
  }
}
