import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/constants.dart';
import 'package:dotlive_schedule/initialize/app_initializer.dart';
import 'package:dotlive_schedule/messaging/messaging_manager.dart';
import 'package:dotlive_schedule/widgets/settings/settings_cache_page.dart';
import 'package:dotlive_schedule/widgets/settings/settings_notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final padding =
        MediaQuery.of(context).padding.copyWith(bottom: defaultBottomMargin);
    return ListView(padding: padding, children: <Widget>[
      _buildTile(Icons.notifications, '通知設定', () {
        _showNotificationPage(context);
      }),
      _buildTile(Icons.cached, 'キャッシュ', () {
        _showCachePage(context);
      }),
      _buildTile(Icons.help, 'ヘルプ', () {
        launch('$baseURL/help');
      }),
      _buildTile(Icons.info, 'ライセンス', () {
        final packageInfo =
            Provider.of<AppInitializer>(context, listen: false).packageInfo;
        showLicensePage(
            context: context,
            // packageInfo.appNameはホームで表示する用の短い名前になっているので直接指定する
            applicationName: 'どっとライブ スケジュール',
            applicationVersion: packageInfo.version);
      }),
    ]);
  }

  Widget _buildTile(IconData icon, String title, GestureTapCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.headline6),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: onTap,
      ),
    );
  }

  void _showNotificationPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      final manager = Provider.of<MessagingManager>(context, listen: false);
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: manager),
        ],
        child: SettingsNotificationPage(),
      );
    }));
  }

  void _showCachePage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      final manager = Provider.of<CalendarManager>(context, listen: false);
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: manager),
        ],
        child: SettingsCachePage(),
      );
    }));
  }
}
