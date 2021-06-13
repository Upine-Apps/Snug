import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:snug/core/errors/AddDateException.dart';
import 'package:snug/core/errors/AddUserException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/create_date/verify_exit.dart';
import 'package:snug/screens/home/contact_date.dart';
import 'package:snug/screens/home/where.dart';
import 'package:snug/screens/home/who.dart';
import 'package:snug/screens/home/when.dart';
import 'package:snug/screens/navigation/MainPage.dart';
import 'package:snug/screens/sync/sync.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/services/remote_db_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';

class AddDate extends StatefulWidget {
  @override
  _AddDateState createState() => _AddDateState();
}

class _AddDateState extends State<AddDate> with WidgetsBindingObserver {
  @override
  final _formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  final dataKey = new GlobalKey();
  Emoji somethingWentWrong = Emoji.byChar(Emojis.flushedFace);

  @override
  void initState() {
    super.initState();
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    dateProvider.addDate(new Date());
  }

  String fName = '';
  Date dateToSend;
  final log = getLogger('AddDate');

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
            'Failed to refresh your session. Please sign in again', context);
        await Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Authenticate()));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => showDialog(
          context: context,
          builder: (BuildContext context) {
            return VerifyExit();
          }),
      child: LoaderOverlay(
        overlayColor: Theme.of(context).colorScheme.secondaryVariant,
        overlayOpacity: 0.8,
        useDefaultLoading: false,
        overlayWidget: Center(
            child: SpinKitPumpingHeart(
                color: Theme.of(context).colorScheme.secondary, size: 50)),
        child: Scaffold(
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
            child: new Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Scrollbar(
                child: new SingleChildScrollView(
                  physics: PageScrollPhysics(),
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Container(
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                                child: Column(
                              children: <Widget>[
                                //**********START OF WHO SECTION**************
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .01,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .025),
                                    child: Container(
                                        padding: EdgeInsets.all(0),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .025,
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(Icons.home,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return VerifyExit();
                                                });
                                          },
                                        ))),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .105),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    height: MediaQuery.of(context).size.height *
                                        .15,
                                    child: Text(
                                      'Tell us a little bit about your date!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 26),
                                    )),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .03),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          .05,
                                      right: MediaQuery.of(context).size.width *
                                          .05),
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * .55,
                                  child: Who(),
                                ),

                                // padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * ),

                                Container(
                                    padding: EdgeInsets.only(
                                        right: MediaQuery.of(context)
                                                .size
                                                .width *
                                            .05),
                                    alignment: Alignment.centerRight,
                                    height: MediaQuery.of(context).size.height *
                                        .07,
                                    child: IconButton(
                                        icon: Icon(Icons.arrow_forward,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryVariant),
                                        onPressed:
                                            () =>
                                                scrollController.animateTo(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.ease)))
                              ],
                            )),
                          )),
                      //************END OF WHO SECTION!***************

                      //****************START OF WHERE SECTION**************

                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Container(
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                  child: Column(children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .01,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .025),
                                    child: Container(
                                        padding: EdgeInsets.all(0),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .025,
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Icon(Icons.home,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return VerifyExit();
                                                  });
                                            }))),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .105),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    height: MediaQuery.of(context).size.height *
                                        .15,
                                    child: Text("Where are y'all headed to?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 26))),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .03),
                                Container(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        top: 0,
                                        bottom: 0),
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        .55,
                                    child: Where()),
                                Container(
                                    height: MediaQuery.of(context).size.height *
                                        .07,
                                    child:
                                        // BELOW WIDGET IS FOR THE TWO FORWARD AND BACKWARD ARROWS TO NAVIGATE

                                        Row(children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .7,
                                              left: MediaQuery.of(context).size.width *
                                                  .05),
                                          child: Container(
                                              padding: EdgeInsets.all(0),
                                              width:
                                                  MediaQuery.of(context).size.width *
                                                      .1,
                                              child: IconButton(
                                                  icon: Icon(Icons.arrow_back,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryVariant),
                                                  onPressed: () =>
                                                      scrollController.animateTo(0,
                                                          duration: Duration(milliseconds: 500),
                                                          curve: Curves.ease)))),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05),
                                          child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .1,
                                              child: IconButton(
                                                  icon: Icon(
                                                      Icons.arrow_forward,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryVariant),
                                                  onPressed: () =>
                                                      scrollController.animateTo(
                                                          MediaQuery.of(context).size.width * 2,
                                                          duration: Duration(milliseconds: 500),
                                                          curve: Curves.ease))))
                                    ]))
                              ])))),
                      //***********END OF WHERE SECTION ****************

                      //*************START OF WHEN SECTION*******************

                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Container(
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                  child: Column(
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .01,
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .025),
                                      child: Container(
                                          padding: EdgeInsets.all(0),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .025,
                                          alignment: Alignment.centerLeft,
                                          child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Icon(Icons.home,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return VerifyExit();
                                                  });
                                            },
                                          ))),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .105),
                                  Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .15,
                                      child: Text("When is this date?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 26))),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .03),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        top: 0,
                                        bottom: 0),
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        .55,

                                    child: When(),

                                    //Insert where widget
                                  ),
                                  Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .07,
                                      child: Row(children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .7,
                                                left: MediaQuery.of(context).size.width *
                                                    .05),
                                            child: Container(
                                                padding: EdgeInsets.all(0),
                                                width:
                                                    MediaQuery.of(context).size.width *
                                                        .1,
                                                child: IconButton(
                                                    icon: Icon(Icons.arrow_back,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondaryVariant),
                                                    onPressed: () => scrollController.animateTo(
                                                        MediaQuery.of(context).size.width,
                                                        duration: Duration(milliseconds: 500),
                                                        curve: Curves.ease)))),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .1,
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_forward,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryVariant),
                                              onPressed: () =>
                                                  scrollController.animateTo(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          3,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease),
                                            ),
                                          ),
                                        )
                                      ]))
                                ],
                              )))),
                      //**********************END OF WHEN SECTION**********************

                      //**********************START OF CONTACT SECTION**********************
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Container(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                .01,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .025),
                                    child: Container(
                                        padding: EdgeInsets.all(0),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .025,
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Icon(Icons.home,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return VerifyExit();
                                                  });
                                            }))),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .105),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    //height:
                                    //MediaQuery.of(context).size.height * .165,
                                    child: Text(
                                        "Which contact would you like to use for this date?",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 26))),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .03),
                                Container(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        top: 0,
                                        bottom: 0),
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        .55,
                                    child: ContactDate()

                                    //INSERT CONTACTS TO CHOOSE FROM
                                    ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * .07,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context).size.width *
                                                  .7,
                                              left: MediaQuery.of(context).size.width *
                                                  .05),
                                          child: Container(
                                              padding: EdgeInsets.all(0),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .1,
                                              child: IconButton(
                                                  icon: Icon(Icons.arrow_back,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryVariant),
                                                  onPressed: () =>
                                                      scrollController.animateTo(
                                                          MediaQuery.of(context).size.width * 2,
                                                          duration: Duration(milliseconds: 500),
                                                          curve: Curves.ease)))),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .05),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .1,
                                          child: IconButton(
                                              icon: Icon(Icons.check,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryVariant),
                                              onPressed: () async {
                                                Date currentDate =
                                                    dateProvider.getRecentDate;
                                                print('Dates');
                                                print(currentDate);
                                                if (DateTime.parse(
                                                        currentDate.dateStart)
                                                    .isAfter(DateTime.parse(
                                                        currentDate.dateEnd))) {
                                                  scrollController.animateTo(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          2,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease);
                                                  CustomToast.showDialog(
                                                      'Please enter a end time that\'s after the start time',
                                                      context);
                                                } else if (currentDate
                                                        .who.phone_number ==
                                                    null) {
                                                  CustomToast.showDialog(
                                                      'Please enter the phone number of your date',
                                                      context);
                                                  scrollController.animateTo(0,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease);
                                                } else if (currentDate
                                                        .who.first_name ==
                                                    null) {
                                                  scrollController.animateTo(0,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease);
                                                  CustomToast.showDialog(
                                                      "Please enter your date's first name",
                                                      context);
                                                } else if (currentDate
                                                        .who.sex ==
                                                    null) {
                                                  scrollController.animateTo(0,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease);
                                                  CustomToast.showDialog(
                                                      "Please enter your date's sex",
                                                      context);
                                                } else if (currentDate
                                                        .dateLocation ==
                                                    null) {
                                                  scrollController.animateTo(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          1,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease);
                                                  CustomToast.showDialog(
                                                      'Please enter the location of the date',
                                                      context);
                                                } else if (currentDate
                                                        .trusted ==
                                                    null) {
                                                  CustomToast.showDialog(
                                                      'Please atleast choose one contact for this date',
                                                      context);
                                                } else {
                                                  SharedPreferences profile =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String user_one_id =
                                                      profile.getString('uid');
                                                  try {
                                                    dynamic userResult =
                                                        await RemoteDatabaseHelper
                                                            .instance
                                                            .addUser(currentDate
                                                                .who); //create the user in the database and get the user id
                                                    if (userResult['status'] ==
                                                        true) {
                                                      currentDate
                                                          .who.uid = userResult[
                                                              'user_id']
                                                          .toString(); //add the user id to currentDate.who
                                                      try {
                                                        dynamic dateResult =
                                                            await RemoteDatabaseHelper
                                                                .instance
                                                                .addDate(
                                                                    currentDate,
                                                                    user_one_id); //add the date to the database

                                                        if (dateResult[
                                                                'status'] ==
                                                            true) {
                                                          log.i(
                                                              'Successfully added date');
                                                          currentDate.dateId =
                                                              dateResult[
                                                                  'data'];
                                                          dateProvider
                                                              .setRecentDate(
                                                                  currentDate);
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DateLoadingScreen()));
                                                        } else {
                                                          throw AddDateException(
                                                              'Failed to add date');
                                                        }
                                                      } catch (e) {
                                                        log.e(
                                                            'Failed to add user. Error: $e');
                                                        dateProvider
                                                            .getCurrentDates
                                                            .removeLast();
                                                        CustomToast.showDialog(
                                                            'Looks like we ran into an error. Please try again later! $somethingWentWrong',
                                                            context);
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MainPage()));
                                                        });
                                                      }
                                                      ;
                                                    } else {
                                                      throw AddUserException(
                                                          'Failed to add the user');
                                                    }
                                                  } catch (e) {
                                                    dateProvider.getCurrentDates
                                                        .removeLast();
                                                    log.e(
                                                        'Failed to add user. Error: $e');
                                                    CustomToast.showDialog(
                                                        'Looks like we ran into an error. Please try again later! $somethingWentWrong',
                                                        context);

                                                    await Future.delayed(
                                                        Duration(seconds: 2),
                                                        () {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MainPage()));
                                                    });
                                                  }
                                                }
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      //**********************END OF CONTACT SECTION**********************
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateLoadingScreen extends StatefulWidget {
  @override
  _DateLoadingScreenState createState() => _DateLoadingScreenState();
}

class _DateLoadingScreenState extends State<DateLoadingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.loaderOverlay.show();
      await Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      });
    });
    return LoaderOverlay(
      overlayColor: Theme.of(context).colorScheme.secondaryVariant,
      overlayOpacity: 0.8,
      useDefaultLoading: false,
      overlayWidget: Center(
          child: SpinKitPumpingHeart(
              color: Theme.of(context).colorScheme.secondary, size: 50)),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ])),
          )),
    );
  }
}
