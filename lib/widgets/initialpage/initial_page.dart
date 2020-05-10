import 'package:dotlive_schedule/initialize/app_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InitialPage extends StatelessWidget {
  final AppInitializer _initializer;
  InitialPage(this._initializer, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initializer.initializeFailed
          ? _buildInitializeFailedBody(context)
          : _buildBody(context),
    );
  }

  Widget _buildInitializeFailedBody(BuildContext context) {
    final themeData = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('初期化に失敗しました', style: themeData.textTheme.headline6),
          Text('通信環境の良い場所でリトライしてください', style: themeData.textTheme.bodyText1),
          RaisedButton(
              onPressed: () => _initializer.reinit(), child: Text('リトライ')),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
