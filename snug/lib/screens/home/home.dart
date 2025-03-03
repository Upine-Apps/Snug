import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/customshowcase.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/models/Contact.dart';
import 'package:snug/models/User.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/LogProvider.dart';
import 'package:snug/providers/MapProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/home/detailed_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:provider/provider.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:toast/toast.dart';

import 'adddate.dart';

class Home extends StatefulWidget {
  @override
  const Home({
    Key key,
  }) : super(key: key);

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  String msg;

  String _date = "Not set";
  String _time = "Not set";
  String _who;
  LocationPermission locationPermission;

  void checkPermissions(MapProvider mp) async {
    Position p = await mp.determinePosition();
    print(p);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //refreshes user auth token for backend verification through cognito

    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      final prefs = await SharedPreferences.getInstance();
      final log = getLogger('refreshAuth', prefs.getString('path'));
      final consoleLog = getConsoleLogger('refreshAuth');
      consoleLog.i('refresh from Home');
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

  bool get wantKeepAlive => true;
  String fname = '';
  String lname = '';
  String _userId = '';

  List<String> _trustedContacts;
  List<String> fnameitems = [];
  List<String> lnameitems = [];

  List<Marker> _markers = <Marker>[];

  final TextEditingController fnameCtrl = new TextEditingController();
  final TextEditingController lnameCtrl = new TextEditingController();

  final bool centerTitle = true;
  //final log = getLogger('Home');

  _convertDateTime(String dateTime) {
    String period;
    String hour;
    String min;

    DateTime realDateTime = DateTime.parse(dateTime);
    DateTime actualDateTime = realDateTime.toLocal();
    //log.i('utc time | ${realDateTime}');
    //log.i('local time | ${actualDateTime} ');
    actualDateTime.hour >= 12 ? period = "PM" : period = "AM";
    actualDateTime.hour > 12
        ? hour = (actualDateTime.hour - 12).toString()
        : hour = actualDateTime.hour.toString();
    if (actualDateTime.hour == 0) {
      hour = 12.toString();
    }

    actualDateTime.minute < 10
        ? min = "0${actualDateTime.minute}"
        : min = "${actualDateTime.minute}";

    return "${actualDateTime.month}/${actualDateTime.day}/${actualDateTime.year}  $hour:$min $period";
  }

  _getContactNames(List contactNumberList) {
    List contactsExist;
    String trusted1;
    String trusted2;
    String trusted3;
    String trusted4;
    String trusted5;

    final contactNameProvider =
        Provider.of<ContactProvider>(context, listen: true);
    List<Contact> potentialTrusted = contactNameProvider.getContacts;

    for (var i in contactNumberList) {
      if (i != 'NULL') {}
      for (Contact c in potentialTrusted) {
        if (c.phoneNumber == i) {
          contactsExist.add(c.name);
        } else {
          contactsExist.add(null);
        }
      }
    }
    return contactsExist;
  }

  bool userHasDate = true;
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context, listen: true);

    final dateProvider = Provider.of<DateProvider>(context, listen: true);
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final contactProvider = Provider.of<ContactProvider>(context, listen: true);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Home', logProvider.getLogPath);
    // checkPermissions(mapProvider);

    if (dateProvider.getCurrentDates.length == 0 ||
        dateProvider.getCurrentDates.length == null) {
      userHasDate = false;
    }
    User _tempUser = userProvider.getUser;
    _userId = _tempUser.uid;
    log.i('In home screen');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Conditional.single(
          context: context,
          conditionBuilder: (BuildContext context) => userHasDate == false,
          widgetBuilder: (BuildContext context) {
            return SafeArea(
              child: Container(
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
                            child: Image.asset(
                          'assets/image/logo1.png',
                          fit: BoxFit.contain,
                          height: 50,
                        )),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .2,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * .15,
                            left: MediaQuery.of(context).size.width * .15),
                        child: Container(
                            child: Text(
                          'All of your dates will appear here',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Theme.of(context).hintColor,
                              fontSize: 24),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          fallbackBuilder: (BuildContext context) {
            return SafeArea(
              child: Container(
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
                        child: Header(
                            child: Image.asset(
                          'assets/image/logo1.png',
                          fit: BoxFit.contain,
                          height: 50,
                        )),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        child: ListView.builder(
                          itemCount: dateProvider.getCurrentDates.length,
                          itemBuilder: (context, index) {
                            _getIndexValue() {
                              print('PRINTING LENGTH OF DATE LIST');

                              print(dateProvider.getCurrentDates.length);
                              int someIndex = index;
                              return someIndex;
                            }

                            return GestureDetector(
                                onTap: () {
                                  log.i(
                                      'Clicked on date ${dateProvider.getCurrentDates[index].who.first_name}, userID: ${dateProvider.getCurrentDates[index].who.uid}');
                                  int someIndex = _getIndexValue();

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailDate(
                                              someIndex: index,
                                            )),
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          .05,
                                      right: MediaQuery.of(context).size.width *
                                          .05),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant,
                                    elevation: 10.0,
                                    child: Row(children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.all(10),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .25,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .25,
                                                decoration: new BoxDecoration(
                                                  image: new DecorationImage(
                                                    fit: BoxFit.fitHeight,
                                                    alignment: FractionalOffset
                                                        .topCenter,
                                                    image: new NetworkImage(
                                                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1920&photoreference=${dateProvider.getCurrentDates[index].photoReference}&key=AIzaSyBQgN0iD8Wo5zNt_FSu_YLreNK9zfwjeKQ',
                                                    ),
                                                  ),
                                                ),
                                              ))),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .55,
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 5, top: 15),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    '${dateProvider.getCurrentDates[index].who.first_name} ${dateProvider.getCurrentDates[index].who.last_name}',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .dividerColor,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .005),
                                              child: Row(
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          right: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .025),
                                                      child: Icon(
                                                        Icons.phone,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      )),
                                                  Text(
                                                    "(" +
                                                        dateProvider
                                                            .getCurrentDates[
                                                                index]
                                                            .who
                                                            .phone_number
                                                            .substring(0, 3) +
                                                        ") - " +
                                                        dateProvider
                                                            .getCurrentDates[
                                                                index]
                                                            .who
                                                            .phone_number
                                                            .substring(3, 6) +
                                                        " - " +
                                                        dateProvider
                                                            .getCurrentDates[
                                                                index]
                                                            .who
                                                            .phone_number
                                                            .substring(6, 10),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .dividerColor,
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .005),
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                          padding: EdgeInsets.only(
                                                              right: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .025),
                                                          child: Icon(
                                                            Icons.place,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                          )),
                                                      Expanded(
                                                        child: Text(
                                                          '${dateProvider.getCurrentDates[index].placeName}',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor,
                                                              fontSize: 16),
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .005),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .025),
                                                        child: Icon(
                                                          Icons.flight_takeoff,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                        )),
                                                    Text(
                                                      _convertDateTime(
                                                          dateProvider
                                                              .getCurrentDates[
                                                                  index]
                                                              .dateStart),
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .dividerColor,
                                                          fontSize: 16),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .005),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            right: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .025),
                                                        child: Icon(
                                                          Icons.flight_land,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                        )),
                                                    Text(
                                                        _convertDateTime(
                                                            dateProvider
                                                                .getCurrentDates[
                                                                    index]
                                                                .dateEnd),
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor,
                                                            fontSize: 16))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                                  ),
                                ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
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
              Icons.favorite,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            log.i('Tapped on create a date button');
            if (contactProvider.getContacts.length == 0) {
              log.i('Did not have at least one contact');
              //log.d('User needs to add a contact before creating a date');

              CustomToast.showDialog(
                  'Please add at least one contact before creating a date',
                  context,
                  Toast.BOTTOM);
            } else {
              try {
                locationPermission = await mapProvider.checkPermissions();
              } catch (e) {
                log.e(e);
                CustomToast.showDialog(e.toString(), context, Toast.BOTTOM);
              }
              if (locationPermission != LocationPermission.always &&
                      locationPermission != LocationPermission.whileInUse ||
                  locationPermission == null) {
                log.i('Location not enabled');
                CustomToast.showDialog(
                    'You need to enable location', context, Toast.BOTTOM);
              } else {
                log.i('Moving to Add Date screen');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AddDate()));
              }
            }
          }),
    );
  }
}
