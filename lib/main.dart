import 'package:dotlive_schedule/initialize/app_initializer.dart';
import 'package:dotlive_schedule/messaging/messaging_manager.dart';
import 'package:dotlive_schedule/widgets/homepage/home_page.dart';
import 'package:dotlive_schedule/widgets/initialpage/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const MaterialColor primaryColorSwatch = MaterialColor(
      0xff00a3ef,
      <int, Color>{
        50: Color(0xffe8f8ff),
        100: Color(0xffc5ecff),
        200: Color(0xff9fe0ff),
        300: Color(0xff79d4ff),
        400: Color(0xff5ccaff),
        500: Color(0xff3fc1ff),
        600: Color(0xff39bbff),
        700: Color(0xff31b3ff),
        800: Color(0xff29abff),
        900: Color(0xff1b9eff),
      },
    );

    const darkAccentColor = Color(0xff00a3ef);

    return MaterialApp(
      title: '.スケジュール',
      theme: ThemeData(
        primarySwatch: primaryColorSwatch,
      ),
      darkTheme: ThemeData.dark().copyWith(
        accentColor: darkAccentColor,
      ),
      home: ChangeNotifierProvider<AppInitializer>(
          create: (_) => AppInitializer(),
          child: Consumer<AppInitializer>(
              builder: (context, initializer, child) {
                if (!initializer.initialized) {
                  return InitialPage(initializer);
                }

                return ChangeNotifierProvider<MessagingManager>.value(
                    value: initializer.messagingManager, child: child);
              },
              child: MyHomePage())),
    );
  }
}
