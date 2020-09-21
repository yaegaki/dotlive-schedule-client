import 'dart:io';

import 'package:dotlive_schedule/calendar/calendar_manager.dart';
import 'package:dotlive_schedule/common/constants.dart';
import 'package:dotlive_schedule/initialize/app_initializer.dart';
import 'package:dotlive_schedule/messaging/messaging_manager.dart';
import 'package:dotlive_schedule/widgets/settings/settings_cache_page.dart';
import 'package:dotlive_schedule/widgets/settings/settings_notification_page.dart';
import 'package:dotlive_schedule/widgets/settings/settings_widget_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const platform =
      const MethodChannel('jp.yaegaki.dotlive-schedule/license');

  @override
  Widget build(BuildContext context) {
    final padding =
        MediaQuery.of(context).padding.copyWith(bottom: defaultBottomMargin);
    final widgets = <Widget>[
      _buildTile(Icons.notifications, '通知設定', () {
        _showNotificationPage(context);
      }),
      _buildTile(Icons.cached, 'キャッシュ', () {
        _showCachePage(context);
      }),
      _buildTile(Icons.help, 'ウィジェット', () {
        _showWidgetPage(context);
      }),
      _buildTile(Icons.help, 'ヘルプ', () {
        launch('$baseURL/help');
      }),
      _buildTile(Icons.info, 'ライセンス', () {
        final packageInfo =
            Provider.of<AppInitializer>(context, listen: false).packageInfo;
        showLicensePage(
            context: context,
            applicationVersion: packageInfo.version);
      }),
    ];
    if (Platform.isAndroid) {
      widgets.add(_buildTile(Icons.info, 'ライセンス(Android)', () {
        platform.invokeMethod('showLicense');
      }));
    }
    return ListView(padding: padding, children: widgets);
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

  void _showWidgetPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsWidgetPage()));
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
