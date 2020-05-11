import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SettingsCachePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('キャッシュ')),
      body: Consumer<CalendarManager>(builder: (context, manager, _) {
        return SingleChildScrollView(
          padding: MediaQuery.of(context).padding,
          child: Card(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('キャッシュ削除',
                    style: Theme.of(context).textTheme.headline6),
                subtitle: Text(
                    'アプリで使用されているキャッシュを削除します\n表示がおかしくなった場合などに削除すると改善される可能性があります'),
              ),
              RaisedButton(
                  child: Text('削除'),
                  onPressed: () {
                    _clearCache(context, manager);
                  }),
            ],
          )),
        );
      }),
    );
  }

  Future<void> _clearCache(
      BuildContext context, CalendarManager manager) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            title: Text('削除中'),
            children: <Widget>[
              Center(child: CircularProgressIndicator()),
            ],
          );
        });

    try {
      await manager.clearAll();
    } catch (e) {}

    Navigator.pop(context);

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('完了'),
            content: Text('削除が完了しました'),
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
