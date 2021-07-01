import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/customshowcase.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/contacts/create_contact.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:snug/core/logger.dart';

class Contact extends StatefulWidget {
  Contact({Key key}) : super(key: key);
  @override
  // const Contact({Key key}) : super(key: key);
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true; //somehow makes it work
  String _phone = '';
  String _name = '';
  String _userId = '';
  final GlobalKey<FormState> _contactFormStateKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = new TextEditingController();
  final TextEditingController phoneCtrl = new TextEditingController();
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool userHasContact = true;
  final log = getLogger('Contact');

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

  Widget build(BuildContext context) {
    final contactList = Provider.of<ContactProvider>(context, listen: true);
    final profileUser = Provider.of<UserProvider>(context, listen: true);
    User _tempUser = profileUser.getUser;
    _userId = _tempUser.uid;

    if (contactList.getContacts.length == 0) {
      userHasContact = false;
    }

    super.build(context); //what does this do
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Conditional.single(
          context: context,
          conditionBuilder: (BuildContext context) => userHasContact == false,
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
                                child: Text(
                              'Contacts',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
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
                              'All of your contacts will appear here',
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 24),
                            )),
                          ),
                        ),
                      ],
                    )));
          },
          fallbackBuilder: (BuildContext context) {
            return SafeArea(
              child: SingleChildScrollView(
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
                            top: MediaQuery.of(context).size.height * .02,
                            bottom: MediaQuery.of(context).size.height * .02,
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height * .05,
                            child: Header(
                                child: Text(
                              'Contacts',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            )),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .875,
                          child: ListView.separated(
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                );
                              },
                              itemCount: contactList.getContacts.length,
                              itemBuilder: (context, index) {
                                if (contactList.getContacts.length != 1) {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    onDismissed: (direction) {
                                      contactList.removeContact(index, _userId);
                                      CustomToast.showDialog('Contact deleted',
                                          context, Toast.BOTTOM);
                                    },
                                    background:
                                        Container(color: Colors.transparent),
                                    child: Column(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            launch(
                                                "tel:${contactList.getContacts[index].phoneNumber}");
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05,
                                            ),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .075,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0)),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryVariant,
                                                  elevation: 10.0,
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: <Widget>[
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .35,
                                                              child: Text(
                                                                '${contactList.getContacts[index].name}',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .dividerColor,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          Text(
                                                            "(" +
                                                                contactList
                                                                    .getContacts[
                                                                        index]
                                                                    .phoneNumber
                                                                    .substring(
                                                                        0, 3) +
                                                                ") - " +
                                                                contactList
                                                                    .getContacts[
                                                                        index]
                                                                    .phoneNumber
                                                                    .substring(
                                                                        3, 6) +
                                                                " - " +
                                                                contactList
                                                                    .getContacts[
                                                                        index]
                                                                    .phoneNumber
                                                                    .substring(
                                                                        6, 10),
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ))),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          launch(
                                              "tel:${contactList.getContacts[index].phoneNumber}");
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .05,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .05,
                                          ),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .075,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant,
                                                elevation: 10.0,
                                                child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: <Widget>[
                                                        Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .35,
                                                            child: Text(
                                                              '${contactList.getContacts[index].name}',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                        Text(
                                                          "(" +
                                                              contactList
                                                                  .getContacts[
                                                                      index]
                                                                  .phoneNumber
                                                                  .substring(
                                                                      0, 3) +
                                                              ") - " +
                                                              contactList
                                                                  .getContacts[
                                                                      index]
                                                                  .phoneNumber
                                                                  .substring(
                                                                      3, 6) +
                                                              " - " +
                                                              contactList
                                                                  .getContacts[
                                                                      index]
                                                                  .phoneNumber
                                                                  .substring(
                                                                      6, 10),
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ))),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }),
                        )
                      ],
                    )),
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
              Icons.person_add,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            if (contactList.getContacts.length == 5) {
              CustomToast.showDialog(
                  'You can only have 5 contacts', context, Toast.BOTTOM);
            } else {
              //////////////////////////////////////////////////
              ////////////  Pop up to create a contact  ////////
              ///
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateContact();
                  });
            }
          }),
    );
  }
}
