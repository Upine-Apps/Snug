import 'dart:async';
import 'dart:io';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/customshowcase.dart';
import 'package:snug/custom_widgets/raise_gradient_circular_button.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/LogProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/profile/profile_edit.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/services/conversion.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:snug/core/logger.dart';
import 'package:toast/toast.dart';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage> with WidgetsBindingObserver {
  String picture;
  List<String> profilePics = [
    'assets/image/pug.jpg',
    'assets/image/dog.jpg',
    'assets/image/dog1.jpg',
    'assets/image/dog2.jpg',
    'assets/image/dog3.jpg',
    'assets/image/dog4.jpg',
    'assets/image/dog5.jpg',
    'assets/image/dog6.jpg',
    'assets/image/dog7.jpg',
    'assets/image/dog8.jpg',
  ];
  var random = new Random();
  TextEditingController _controller;
  final Conversion _conversion = Conversion();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = new TextEditingController();

    setProfilePic();
  }

  setProfilePic() async {
    final _userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('profilePicture') != null) {
      setState(() {
        picture = prefs.getString('profilePicture');
      });
    } else {
      setState(() {
        picture = 'assets/image/pug.jpg';
      });
      prefs.setString('profilePicture', picture);
    }
    _userProvider.setProfilePic(picture);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //final log = getLogger('Profile');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //refreshes user auth token for backend verification through cognito

    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      final prefs = await SharedPreferences.getInstance();
      final log = getLogger('refreshAuth', prefs.getString('path'));
      final consoleLog = getConsoleLogger('refreshAuth');
      consoleLog.i('refresh from Profile');
      log.i('AppState: $state');
      log.d('Current user auth token: ${prefs.getString('accessToken')}');
      consoleLog.i('AppState: $state');
      consoleLog
          .d('Current user auth token: ${prefs.getString('accessToken')}');
      final _userProvider = Provider.of<UserProvider>(context, listen: false);
      log.i('CognitoService.refreshAuth');
      consoleLog.i('CognitoService.refreshAuth');
      Map<String, dynamic> refreshResponse = await CognitoService.instance
          .refreshAuth(
              _userProvider.getCognitoUser, prefs.getString('refreshToken'));
      log.d('refreshResponse: ${refreshResponse['status']}');
      consoleLog.d('refreshResponse: ${refreshResponse['status']}');
      if (refreshResponse['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        log.i('Successfully refreshed user session');
        consoleLog.i('Successfully refreshed user session');
        CognitoUserSession userSession = refreshResponse['data'];
        _userProvider.setUserSession(userSession);
        log.d('New user auth token: ${prefs.getString('accessToken')}');
        consoleLog.d('New user auth token: ${prefs.getString('accessToken')}');
      } else {
        log.e('Failed to refresh user session. Returning to home screen');
        consoleLog
            .e('Failed to refresh user session. Returning to home screen');
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

  final FocusNode myFocusNode = FocusNode();

  _convertDob(String dob) {
    //log.i(dob);
    String year = dob.substring(0, 4);
    String month = dob.substring(5, 7);
    String day = dob.substring(8, 10);
    String dateOfBirth = '$month/$day/$year';
    return dateOfBirth;
  }

  getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var currentProfilePic =
        profilePics.indexOf(prefs.getString("profilePicture"));
    final _userProvider = Provider.of<UserProvider>(context, listen: false);
    //log.i(currentProfilePic);
    currentProfilePic != profilePics.length - 1
        ? currentProfilePic += 1
        : currentProfilePic = 0;
    String nextPic = profilePics[currentProfilePic];
    setState(() {
      picture = nextPic;
      prefs.setString("profilePicture", nextPic);
    });
    _userProvider.setProfilePic(nextPic);
  }

  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Profile', logProvider.getLogPath);
    User currentUser = userProvider.getUser;

    File _image;

    final _formKey = GlobalKey<FormState>();
    return new Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        body: new Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: new ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .02),
                child: Container(
                  height: MediaQuery.of(context).size.height * .05,
                  child: Header(
                      child: Text(
                    'Profile',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondaryVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  )),
                ),
              ),
              Column(
                children: <Widget>[
                  new Container(
                    height: 250.0,
                    // color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 20.0),
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[],
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child:
                              new Stack(fit: StackFit.loose, children: <Widget>[
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                picture == null
                                    ? CircularProgressIndicator()
                                    : Container(
                                        width: 140.0,
                                        height: 140.0,
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            image: new ExactAssetImage(picture),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                              ],
                            ),
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 90.0, right: 100.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                        //CHECK TO SEE IF THIS FUNCTIONS WORKS ON A REAL MOBILE
                                        onTap: getImage,
                                        child: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primaryVariant,
                                          radius: 25.0,
                                          child: new Icon(
                                            Icons.pets,
                                            color: Colors.white,
                                          ),
                                        ))
                                  ],
                                )),
                          ]),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryVariant,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    child: RaisedCircularGradientButton(
                                        elevation: 2,
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          log.i('Profile edit popup');
                                          SharedPreferences profile =
                                              await SharedPreferences
                                                  .getInstance();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ProfileEdit();
                                              });
                                        }))
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25, right: 25.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Name',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25.0,
                              top: 5,
                            ),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                        '${currentUser.first_name} ${currentUser.last_name}')
                                  ],
                                ))
                              ],
                            )),
                        Divider(
                          indent: 25,
                          endIndent: 25,
                          color: Theme.of(context).hintColor,
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25, right: 25.0, top: 15.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Date Of Birth',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25.0,
                              top: 5,
                            ),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(_convertDob(currentUser.dob))
                                  ],
                                ))
                              ],
                            )),
                        Divider(
                          indent: 25,
                          endIndent: 25,
                          color: Theme.of(context).hintColor,
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 15.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: new Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        'Sex',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryVariant),
                                      ),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Flexible(
                                  child: new Container(
                                    child: Text(
                                      'Race',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 5.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: new Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        _conversion.convertSex(currentUser.sex),
                                      ),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Flexible(
                                  child: new Container(
                                    child: Text(
                                      _conversion.convertRace(currentUser.race),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Divider(
                          indent: 25,
                          endIndent: 25,
                          color: Theme.of(context).hintColor,
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 15.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Text(
                                    'Eye Color',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryVariant),
                                  ),
                                ),
                                new Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Text(
                                    'Hair Color',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryVariant),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Height',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryVariant),
                                  ),
                                )
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 5.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  alignment: Alignment.centerLeft,
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Text(
                                    _conversion.convertEye(currentUser.eye),
                                  ),
                                ),
                                new Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Text(
                                    _conversion.convertHair(currentUser.hair),
                                  ),
                                ),
                                new Container(
                                    child: Text(
                                        "${currentUser.ft}' ${currentUser.inch}\""))
                              ],
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 25,
                            right: 25.0,
                            top: 5,
                          ),
                        ),
                        Divider(
                            indent: 25,
                            endIndent: 25,
                            color: Theme.of(context).hintColor),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 15.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  child: Text(
                                    'Zip',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryVariant),
                                  ),
                                )
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 5.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(child: Text("${currentUser.zip}"))
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
