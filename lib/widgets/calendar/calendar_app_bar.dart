import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("カレンダー"),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

