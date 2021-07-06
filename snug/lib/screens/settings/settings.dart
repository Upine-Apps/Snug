import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/customshowcase.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/walkthrough/walkthrough.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/settings/verifydelete.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/themes/colors.dart';
import 'package:snug/themes/constants.dart';
import 'package:snug/themes/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snug/core/logger.dart';
import 'package:toast/toast.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingScreen> with WidgetsBindingObserver {
  GlobalKey logOut = GlobalKey();
  int _selectedPosition;
  var isDarkTheme;
  List themes = Constants.themes;
  SharedPreferences prefs;
  ThemeNotifier themeNotifier;
  final log = getLogger('Settings');

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _getSavedTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _getSavedTheme() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPosition = themes.indexOf(prefs.getString("Theme"));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // I think this will successfully refresh the user session
    log.i("APP_STATE: $state");

    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      final prefs = await SharedPreferences.getInstance();
      log.i('Current user auth token: ${prefs.getString('accessToken')}');
      final _userProvider = Provider.of<UserProvider>(context, listen: false);
      Map<String, dynamic> refreshResponse = await CognitoService.instance
          .refreshAuth(
              _userProvider.getCognitoUser, prefs.getString('refreshToken'));
      if (refreshResponse['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        log.i('Successfully refreshed user session');
        CognitoUserSession userSession = refreshResponse['data'];
        _userProvider.setUserSession(userSession);
        log.i('New user auth token: ${prefs.getString('accessToken')}');
      } else {
        log.e('Failed to refresh user session. Returning to home screen');
        CustomToast.showDialog(
            'Failed to refresh your session. Please sign in again',
            context,
            Toast.BOTTOM);
        await Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Authenticate()));
        });
      }
    }
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
                child: Container(
                  height: MediaQuery.of(context).size.height * .05,
                  child: Header(
                      child: Text(
                    'Settings',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondaryVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    top: MediaQuery.of(context).size.height * .01),
                child: Column(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Themes',
                          style: TextStyle(
                              color: Theme.of(context).hintColor, fontSize: 16),
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * .125,
                      child: ListView.builder(
                        itemBuilder: (context, position) {
                          return _createList(
                              context, themes[position], position);
                        },
                        itemCount: themes.length,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    top: MediaQuery.of(context).size.height * .01),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * .01),
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Account Management',
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 16),
                          )),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: FlatButton(
                          color: Theme.of(context).colorScheme.secondaryVariant,
                          onPressed: () async => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return VerifyDelete();
                              }),
                          child: Container(
                              width: MediaQuery.of(context).size.width * .40,
                              padding: EdgeInsets.all(0),
                              height: MediaQuery.of(context).size.height * .025,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Delete Account',
                                style: TextStyle(
                                    color: Theme.of(context).dividerColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ))),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    top: MediaQuery.of(context).size.height * .01),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * .01),
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Knowledge Base',
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 16),
                          )),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: FlatButton(
                          color: Theme.of(context).colorScheme.secondaryVariant,
                          onPressed: () async => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Walkthrough()),
                              ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * .40,
                              padding: EdgeInsets.all(0),
                              height: MediaQuery.of(context).size.height * .025,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Snug Walkthrough',
                                style: TextStyle(
                                    color: Theme.of(context).dividerColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ))),
                    )
                  ],
                ),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final contactProvider =
                Provider.of<ContactProvider>(context, listen: false);
            final dateProvider =
                Provider.of<DateProvider>(context, listen: false);
            if (dateProvider.getCurrentDates.length != null) {
              dateProvider.removeAllDates();
            }
            if (contactProvider.getContacts.length != null) {
              contactProvider.removeAllContacts();
            }
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);
            CognitoUser cognitoUser = userProvider.getCognitoUser;
            await CognitoService.instance.logoutUser(cognitoUser);

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
