import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/customshowcase.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/contacts/create_contact.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  Contact({Key key}) : super(key: key);
  @override
  // const Contact({Key key}) : super(key: key);
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> with AutomaticKeepAliveClientMixin {
  @override
  GlobalKey addContact = GlobalKey();
  GlobalKey deleteContact = GlobalKey();
  bool get wantKeepAlive => true; //somehow makes it work
  String _phone = '';
  String _name = '';
  String _userId = '';
  final GlobalKey<FormState> _contactFormStateKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = new TextEditingController();
  final TextEditingController phoneCtrl = new TextEditingController();
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contactFirstLaunch().then((result) {
        if (result)
          ShowCaseWidget.of(context).startShowCase(
            [addContact],
          );
      });

      _deleteContact().then((result) {
        if (result) ShowCaseWidget.of(context).startShowCase([deleteContact]);
      });

      // MAKE SURE TO CHECK TO SEE IF THE SHOWCASE WIDGET POPS UP FOR THIS.
    });
  }

  Future<bool> _contactFirstLaunch() async {
    SharedPreferences _contactTutorial = await SharedPreferences.getInstance();
    if (_contactTutorial.getBool('contactTutorial') == null) {
      _contactTutorial.setBool('contactTutorial', true);
    }

    return _contactTutorial.getBool('contactTutorial');
  }

  Future<bool> _deleteContact() async {
    SharedPreferences _deleteContact = await SharedPreferences.getInstance();
    if (_deleteContact.getBool('deleteContact') == null) {
      _deleteContact.setBool('deleteContact', true);
    }
    return _deleteContact.getBool('deleteContact');
  }

  bool userHasContact = true;

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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .2,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              child: Text(
                            'All of your Contacts will appear here',
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 24),
                          )),
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
                        Container(
                          height: MediaQuery.of(context).size.height * .8,
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
                                      CustomToast.showDialog(
                                          'Contact deleted', context);
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
          child: CustomShowCase(
            globalKey: addContact,
            description: 'Add your contacts here',
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
          ),
          onPressed: () {
            if (contactList.getContacts.length == 5) {
              CustomToast.showDialog('You can only have 5 contacts', context);
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
