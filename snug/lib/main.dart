import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/MapProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/themes/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snug/themes/themeNotifier.dart';
import 'package:snug/themes/apptheme.dart';
import 'package:logger/logger.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (BuildContext context) {
          String theme = value.getString(Constants.APP_THEME);
          if (theme == null ||
              theme == "" ||
              theme == Constants.SYSTEM_DEFAULT) {
            value.setString(Constants.APP_THEME, Constants.SYSTEM_DEFAULT);
            return ThemeNotifier(ThemeMode.light);
          }
          return ThemeNotifier(
              theme == Constants.DARK ? ThemeMode.dark : ThemeMode.light);
        },
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  //
  final log = Logger(
      printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 3,
          lineLength: 50,
          colors: true,
          printEmojis: true,
          printTime: true));
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ContactProvider()),
          ChangeNotifierProvider(create: (context) => DateProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => MapProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Authenticate(),
          theme: AppTheme().lightTheme,
          darkTheme: AppTheme().darkTheme,
          themeMode: themeNotifier.getThemeMode(),
        ));
  }
}
