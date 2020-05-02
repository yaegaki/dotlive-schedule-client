import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("設定"),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
