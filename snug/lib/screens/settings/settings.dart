import 'package:flutter/material.dart';
import 'package:snug/custom_widgets/customshowcase.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/themes/colors.dart';
import 'package:snug/themes/constants.dart';
import 'package:snug/themes/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingScreen> {
  GlobalKey logOut = GlobalKey();
  int _selectedPosition = 0;
  var isDarkTheme;
  List themes = Constants.themes;
  SharedPreferences prefs;
  ThemeNotifier themeNotifier;

  @override
  void initState() {
    super.initState();
  }

  _getSavedTheme() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPosition = themes.indexOf(
          prefs.getString(Constants.APP_THEME) ?? Constants.SYSTEM_DEFAULT);
    });
  }

  @override
  Widget build(BuildContext context) {
    isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ])),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .02),
                child: Header(
                    child: Text(
                  'Settings',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondaryVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                )),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * .125,
                  child: ListView.builder(
                    itemBuilder: (context, position) {
                      return _createList(context, themes[position], position);
                    },
                    itemCount: themes.length,
                  ),
                ),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            final contactProvider =
                Provider.of<ContactProvider>(context, listen: false);
            final dateProvider =
                Provider.of<DateProvider>(context, listen: false);
            if (dateProvider.getCurrentDates.length != null) {
              for (var i = 0; i < dateProvider.getCurrentDates.length; i + 1) {
                dateProvider.removeDate(i);
              }
            }
            if (contactProvider.getContacts.length != null) {
              for (var y = 0; y < contactProvider.getContacts.length; y + 1) {
                contactProvider.removeContactFromProvider(y);
              }
            }
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Authenticate()));
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle, // circular shape
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryVariant,
                  Theme.of(context).colorScheme.secondaryVariant,
                ],
              ),
            ),
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )),
    );
  }

  _createList(context, item, position) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        _updateState(position);
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Radio(
            value: _selectedPosition,
            groupValue: position,
            activeColor: isDarkTheme ? AppColors.darkPink : AppColors.textBlack,
            onChanged: (_) {
              _updateState(position);
            },
          ),
          Text(item),
        ],
      ),
    );
  }

  _updateState(int position) {
    setState(() {
      _selectedPosition = position;
    });
    onThemeChanged(themes[position]);
  }

  void onThemeChanged(String value) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == Constants.DARK) {
      themeNotifier.setThemeMode(ThemeMode.dark);
    } else {
      themeNotifier.setThemeMode(ThemeMode.light);
    }
    prefs.setString(Constants.APP_THEME, value);
  }
}
