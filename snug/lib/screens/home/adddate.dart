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
import 'package:snug/providers/LogProvider.dart';
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
import 'package:toast/toast.dart';

class AddDate extends StatefulWidget {
  @override
  _AddDateState createState() => _AddDateState();
}

class _AddDateState extends State<AddDate> {
  @override
  final _formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  final dataKey = new GlobalKey();
  bool didSubmitDate = false;
  Emoji somethingWentWrong = Emoji.byChar(Emojis.flushedFace);

  @override
  void initState() {
    super.initState();
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    dateProvider.addDate(new Date());
  }

  String fName = '';
  Date dateToSend;

// final log = getLogger('AddDate');
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Add Date', logProvider.getLogPath);

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
        child: GestureDetector(
          onTap: () {
            log.i('Tapped on screen outside of fields');
            FocusScope.of(context).requestFocus(new FocusNode());
          },
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
                                              log.i(
                                                  'Pressed home icon button on who section');
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
                                              .05),
                                  // Container(
                                  //   width:
                                  //       MediaQuery.of(context).size.width / 2,
                                  //   height: MediaQuery.of(context).size.height *
                                  //       .15,
                                  //   child: Text(
                                  //     'Tell us a little bit about your date!',
                                  //     textAlign: TextAlign.center,
                                  //     style: TextStyle(fontSize: 26),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //     height:
                                  //         MediaQuery.of(context).size.height *
                                  //             .02),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                .05),
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height * .8,
                                    child: Who(),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                .02),
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryVariant,
                                          ),
                                          onPressed: () {
                                            log.i(
                                                'Pressed next button on who page');
                                            scrollController.animateTo(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.ease);
                                          }),
                                    ),
                                  ),
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
                                                log.i(
                                                    'Pressed home button on where section');
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return VerifyExit();
                                                    });
                                              }))),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .05),
                                  Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .15,
                                      child: Text("Where are y'all headed to?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 26))),
                                  // SizedBox(
                                  //     height:
                                  //         MediaQuery.of(context).size.height *
                                  //             .02),
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .05,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .05,
                                          top: 0,
                                          bottom: 0),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .65,
                                      child: Where()),
                                  Container(
                                      child:
                                          // BELOW WIDGET IS FOR THE TWO FORWARD AND BACKWARD ARROWS TO NAVIGATE

                                          Row(children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .7,
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .02,
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                            onPressed: () {
                                              log.i(
                                                  'Pressed back button on where screen');
                                              scrollController.animateTo(0,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.ease);
                                            }),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .02,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .05),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .1,
                                        child: IconButton(
                                          icon: Icon(Icons.arrow_forward,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant),
                                          onPressed: () {
                                            log.i(
                                                'Pressed forward button on where button');
                                            scrollController.animateTo(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    2,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.ease);
                                          },
                                        ),
                                      ),
                                    ),
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
                                                log.i(
                                                    'Pressed home button on where screen');
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
                                                .05),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .15,
                                        child: Text("When is this date?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 26))),
                                    // SizedBox(
                                    //     height:
                                    //         MediaQuery.of(context).size.height *
                                    //             .02),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .05,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .05,
                                          top: 0,
                                          bottom: 0),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .65,

                                      child: When(),

                                      //Insert where widget
                                    ),
                                    Container(
                                        child: Row(children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .7,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .05,
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .02,
                                          ),
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
                                                  onPressed: () {
                                                    log.i(
                                                        'Pressed back button on phone');
                                                    scrollController.animateTo(
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease);
                                                  }))),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .02,
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
                                            onPressed: () {
                                              log.i(
                                                  'Pressed forward button on where section');
                                              scrollController.animateTo(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      3,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.ease);
                                            },
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
                                                log.i(
                                                    'Pressed home button on add contact section');
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return VerifyExit();
                                                    });
                                              }))),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .05),
                                  Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .2,
                                      child: Text(
                                          "Which contact would you like to use for this date?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 26))),
                                  // SizedBox(
                                  //     height:
                                  //         MediaQuery.of(context).size.height *
                                  //             .02),
                                  Container(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .05,
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .05,
                                          top: 0,
                                          bottom: 0),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .6,
                                      child: ContactDate()

                                      //INSERT CONTACTS TO CHOOSE FROM
                                      ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .7,
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05,
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .02,
                                            ),
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
                                                  onPressed: () {
                                                    log.i(
                                                        'Pressed back button on add contact section');
                                                    scrollController.animateTo(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            2,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease);
                                                  },
                                                ))),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .02,
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
                                                  log.i(
                                                      'Pressed check to add date');
                                                  Date currentDate =
                                                      dateProvider
                                                          .getRecentDate;

                                                  if (currentDate.dateEnd ==
                                                          null ||
                                                      currentDate
                                                          .dateEnd.isEmpty) {
                                                    log.i(
                                                        'No end time selected for date');
                                                    scrollController.animateTo(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            2,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease);
                                                    CustomToast.showDialog(
                                                        'Please enter an end time',
                                                        context,
                                                        Toast.BOTTOM);
                                                  } else if (currentDate
                                                              .dateStart ==
                                                          null ||
                                                      currentDate
                                                          .dateStart.isEmpty) {
                                                    log.i(
                                                        'No start time selected for date');
                                                    scrollController.animateTo(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            2,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease);
                                                    CustomToast.showDialog(
                                                        'Please enter a start time',
                                                        context,
                                                        Toast.BOTTOM);
                                                  } else if (DateTime.parse(
                                                          currentDate.dateStart)
                                                      .isAfter(DateTime.parse(
                                                          currentDate
                                                              .dateEnd))) {
                                                    log.i(
                                                        'End time behind start time');
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
                                                        context,
                                                        Toast.BOTTOM);
                                                  } else if (currentDate
                                                          .who.phone_number ==
                                                      null) {
                                                    log.i(
                                                        'No date phone number enterd');

                                                    CustomToast.showDialog(
                                                        'Please enter the phone number of your date',
                                                        context,
                                                        Toast.BOTTOM);
                                                    scrollController.animateTo(
                                                        0,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease);
                                                  } else if (currentDate
                                                          .who.first_name ==
                                                      null) {
                                                    log.i(
                                                        'First name of date not entered');
                                                    scrollController.animateTo(
                                                        0,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease);
                                                    CustomToast.showDialog(
                                                        "Please enter your date's first name",
                                                        context,
                                                        Toast.BOTTOM);
                                                  } else if (currentDate
                                                          .who.sex ==
                                                      null) {
                                                    log.i(
                                                        'Sex of date not entered');
                                                    scrollController.animateTo(
                                                        0,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease);
                                                    CustomToast.showDialog(
                                                        "Please enter your date's sex",
                                                        context,
                                                        Toast.BOTTOM);
                                                  } else if (currentDate
                                                              .dateLocation ==
                                                          null ||
                                                      currentDate.dateLocation[
                                                              'x'] ==
                                                          null ||
                                                      currentDate.dateLocation[
                                                              'y'] ==
                                                          null) {
                                                    log.i(
                                                        'Location for date not entered');
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
                                                        context,
                                                        Toast.BOTTOM);
                                                  } else if (currentDate
                                                          .trusted.isEmpty ||
                                                      currentDate.trusted ==
                                                          null) {
                                                    log.i(
                                                        'No contacts chosen for date');
                                                    CustomToast.showDialog(
                                                        'Please choose at least one contact for this date',
                                                        context,
                                                        Toast.BOTTOM);
                                                  } else {
                                                    if (didSubmitDate ==
                                                        false) {
                                                      //fix double tap issue
                                                      setState(() {
                                                        didSubmitDate = true;
                                                      });

                                                      SharedPreferences
                                                          profile =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      String user_one_id =
                                                          profile
                                                              .getString('uid');
                                                      try {
                                                        log.i(
                                                            'RemoteDatabaseHelper.addUser');
                                                        dynamic userResult =
                                                            await RemoteDatabaseHelper
                                                                .instance
                                                                .addUser(
                                                                    currentDate
                                                                        .who);

                                                        log.d(userResult[
                                                            'status']); //create the user in the database and get the user id
                                                        if (userResult[
                                                                'status'] ==
                                                            true) {
                                                          log.d(
                                                              'user id: ${userResult['user_id']}');
                                                          currentDate.who
                                                              .uid = userResult[
                                                                  'user_id']
                                                              .toString(); //add the user id to currentDate.who
                                                          try {
                                                            log.d(
                                                                'RemoteDatabaseHelper.instance.addDate');
                                                            dynamic dateResult =
                                                                await RemoteDatabaseHelper
                                                                    .instance
                                                                    .addDate(
                                                                        currentDate,
                                                                        user_one_id); //add the date to the database
                                                            log.d(dateResult[
                                                                'status']);
                                                            if (dateResult[
                                                                    'status'] ==
                                                                true) {
                                                              log.i(
                                                                  'Successfully added date');
                                                              log.d('Date id: ' +
                                                                  dateResult[
                                                                      'data']);
                                                              currentDate
                                                                      .dateId =
                                                                  dateResult[
                                                                      'data'];
                                                              log.d(
                                                                  'dateProvider.setRecentDate');
                                                              dateProvider
                                                                  .setRecentDate(
                                                                      currentDate);
                                                              log.i(
                                                                  'Sent to DateLoadingScreen');
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
                                                          } on AddDateException catch (e) {
                                                            log.e(
                                                                'Failed to add date. Error: $e');
                                                            dateProvider
                                                                .getCurrentDates
                                                                .removeLast();
                                                            CustomToast.showDialog(
                                                                'We ran into an error adding your date. Please try again later! $somethingWentWrong',
                                                                context,
                                                                Toast.BOTTOM);
                                                            log.i(
                                                                'Sent to MainPage');
                                                            await Future
                                                                .delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            2),
                                                                    () {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              MainPage()));
                                                            });
                                                          } catch (e) {
                                                            log.e(
                                                                'Failed to add date. Error: $e');
                                                            dateProvider
                                                                .getCurrentDates
                                                                .removeLast();
                                                            CustomToast.showDialog(
                                                                'Looks like we ran into an error. Please try again later! $somethingWentWrong',
                                                                context,
                                                                Toast.BOTTOM);
                                                            log.i(
                                                                'Sent to MainPage');
                                                            await Future
                                                                .delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            2),
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
                                                        dateProvider
                                                            .getCurrentDates
                                                            .removeLast();
                                                        log.e(
                                                            'Failed to add user. Error: $e');
                                                        CustomToast.showDialog(
                                                            'Looks like we ran into an error. Please try again later! $somethingWentWrong',
                                                            context,
                                                            Toast.BOTTOM);
                                                        log.i(
                                                            'Sent to MainPage');
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
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Date Loading Screen', logProvider.getLogPath);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.loaderOverlay.show();
      log.i('In date loading screen sending to MainPage');
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
