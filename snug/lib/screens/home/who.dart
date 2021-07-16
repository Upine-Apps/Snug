import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/eye.dart';
import 'package:snug/custom_widgets/feet.dart';
import 'package:snug/custom_widgets/gender.dart';
import 'package:snug/custom_widgets/hair.dart';
import 'package:snug/custom_widgets/inch.dart';
import 'package:snug/custom_widgets/race.dart';
import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/LogProvider.dart';
import 'package:snug/services/remote_db_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:toast/toast.dart';
import 'package:snug/providers/UserProvider.dart';

class ShowToastComponent {
  static showDialog(String msg, context) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Theme.of(context).dividerColor,
        backgroundColor: Theme.of(context).colorScheme.secondaryVariant);
  }
}

class Who extends StatefulWidget {
  @override
  _WhoState createState() => _WhoState();
}

class _WhoState extends State<Who> {
  bool triedToFindUser = false;
  bool userFound = false;
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();

  //final log = getLogger('addDate: who');
  Date currentDate;

  String phone_number;
  String _firstName;
  String _lastName;
  String _sex;
  String _race;
  String _eye;
  String _hair;
  String _ft;
  String _in;
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _whoFormKey = GlobalKey<FormState>();
  final _whoFormKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    currentDate = dateProvider.getRecentDate;
    currentDate.who = new User();
  }

  findUser(DateProvider dateProvider, LogProvider logProvider) async {
    final log = getLogger('Who Section', logProvider.getLogPath);
    setState(() {
      triedToFindUser = true;
    });

    try {
      log.d('RemoteDatabaseHelper.instance.getRegisteredUserByPhone');
      //only returning the registered user not a reported user
      dynamic result = await RemoteDatabaseHelper.instance
          .getRegisteredUserByPhone(phone_number);
      log.d(result['status']);

      if (result['status'] == true) {
        User userResult = User.fromMap(result['data']);
        log.d('User found (user id): ' + userResult.uid);

        //set widgets with user data
        _fNameController.text = userResult.first_name;
        _lNameController.text = userResult.last_name;
        _phoneController.text = phone_number;
        _firstName = userResult.first_name;
        _lastName = userResult.last_name;

        _race = userResult.race;
        _sex = userResult.sex;
        _eye = userResult.eye;
        _hair = userResult.hair;
        _ft = userResult.ft;
        _in = userResult.inch;

        userResult.temp = 'true';
        userResult.legal = 'false';

        //set current user 2 info to user data
        currentDate.who = userResult;
        log.d(
            'set current user 2 info to user data -> dateProvider.setRecentDate');
        dateProvider.setRecentDate(currentDate);

        setState(() {
          userFound = true;
        });

        CustomToast.showDialog(
            'Does the user info look right?', context, Toast.BOTTOM);
      } else {
        //user not found in database
        log.d('User not found in database');

        CustomToast.showDialog('Couldn\'t find user', context, Toast.BOTTOM);
        _phoneController.text = phone_number;
      }
    } catch (e) {
      log.e(e);
      CustomToast.showDialog('Error finding user. Please try later!', context,
          Toast.BOTTOM); //add emoji :'(
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Who Section', logProvider.getLogPath);

    return Container(
        child: Conditional.single(
            context: context,
            conditionBuilder: (BuildContext context) =>
                triedToFindUser == false,
            widgetBuilder: (BuildContext context) {
              return Column(children: <Widget>[
                Container(
                    child: Form(
                  key: _whoFormKey,
                  child: Column(children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        'Tell us a little bit about your date!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .07,
                    ),
                    Container(
                        child: TextFormField(
                            inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]+')),
                        ],
                            validator: (String val) {
                              if (val.length != 10) {
                                return "Please enter a valid Phone Number";
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelText: 'Phone Number'),
                            onChanged: (val) {
                              setState(() {
                                phone_number = val;
                              });
                            },
                            onTap: () {
                              log.i('Pressed text field for phone number');
                            })),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .03,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .8,
                      child: Text(
                        'Don\'t worry we won\'t contact your date.\n It\'s just for your safety!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .03),
                        child: Container(
                            child: RaisedRoundedGradientButton(
                                child: Text('Check for user',
                                    style: TextStyle(
                                        color: Theme.of(context).dividerColor)),
                                onPressed: () async {
                                  log.i('Pressed check for user button');

                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  if (_whoFormKey.currentState.validate()) {
                                    if (userProvider.getUser.phone_number ==
                                        phone_number) {
                                      log.i('User entered their phone number');
                                      CustomToast.showDialog(
                                          "You going on a date with yourself?",
                                          context,
                                          Toast.BOTTOM);
                                    } else {
                                      log.d('findUser');
                                      findUser(dateProvider, logProvider);
                                    }
                                  }
                                }))),
                  ]),
                ))
              ]);
            },
            fallbackBuilder: (BuildContext context) {
              return Container(
                  child: Form(
                key: _whoFormKey1,
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height * .15,
                    child: Text(
                      'Tell us a little bit about your date!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height * .083,
                      child: TextFormField(
                        enabled: false,
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black54),
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            labelText: 'Phone Number'),
                        onChanged: (val) {
                          setState(() {
                            phone_number = val;
                          });
                        },
                      )),
                  Container(
                      height: MediaQuery.of(context).size.height * .083,
                      child: Row(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * .1),
                              child: Container(
                                width: MediaQuery.of(context).size.width * .4,
                                child: TextFormField(
                                  focusNode: firstNameFocusNode,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(lastNameFocusNode),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r"[a-zA-Z\-\ ]")),
                                  ],
                                  validator: (String val) {
                                    if (val.length > 30) {
                                      return "They got a shorter first name?";
                                    } else if (val.length == 0) {
                                      return "What's their first name?";
                                    }
                                  },
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black54),
                                  controller: _fNameController,
                                  decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      labelText: 'First Name'),
                                  onChanged: (val) {
                                    setState(() {
                                      _firstName = val;
                                    });
                                  },
                                  onTap: () {
                                    log.i('Pressed first name field');
                                  },
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width * .4,
                              child: TextFormField(
                                focusNode: lastNameFocusNode,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                validator: (String val) {
                                  if (val.length > 30) {
                                    return "They got a shorter last name?";
                                  } else if (val.length == 0) {
                                    return "What's their last name?";
                                  }
                                },
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black54),
                                controller: _lNameController,
                                decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryVariant),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    labelText: 'Last Name'),
                                onChanged: (val) {
                                  setState(() {
                                    _lastName = val;
                                  });
                                },
                                onTap: () {
                                  log.i('Pressed last name field');
                                },
                              )),
                        ],
                      )),
                  Container(
                      child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * .1,
                        ),
                        child: Container(
                            padding: EdgeInsets.all(0),
                            width: MediaQuery.of(context).size.width * .4,
                            child: Gender(
                              validator: (val) {
                                if (val == null) {
                                  return "Please choose his/her race.";
                                }
                              },
                              onChanged: (String val) {
                                log.i('Pressed sex field');
                                setState(() {
                                  _sex = val;
                                });
                              },
                              value: _sex,
                            )),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * .4,
                          child: Race(
                            validator: (val) {
                              if (val == null) {
                                return "Please choose his/her race.";
                              }
                            },
                            onChanged: (String val) {
                              log.i('Pressed race field');
                              setState(() {
                                _race = val;
                              });
                            },
                            value: _race,
                          )),
                    ],
                  )),
                  Container(
                      child: Column(children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * .1),
                            child: Container(
                                width: MediaQuery.of(context).size.width * .4,
                                child: Eye(
                                  validator: (val) {
                                    if (val == null) {
                                      return "Please choose their eye color.";
                                    }
                                  },
                                  onChanged: (String val) {
                                    log.i('Pressed eye field');
                                    setState(() {
                                      _eye = val;
                                    });
                                  },
                                  value: _eye,
                                ))),
                        Container(
                            width: MediaQuery.of(context).size.width * .4,
                            child: Hair(
                              validator: (val) {
                                if (val == null) {
                                  return "Please choose their hair color";
                                }
                              },
                              onChanged: (String val) {
                                log.i('Pressed hair field');
                                setState(() {
                                  _hair = val;
                                });
                              },
                              value: _hair,
                            )),
                      ],
                    ),
                  ])),
                  Container(
                      child: Column(children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * .1),
                            child: Container(
                                width: MediaQuery.of(context).size.width * .4,
                                child: Feet(
                                  validator: (val) {
                                    if (val == null) {
                                      return "Please choose their height";
                                    }
                                  },
                                  onChanged: (String val) {
                                    log.i('Pressed feet field');
                                    setState(() {
                                      _ft = val;
                                    });
                                  },
                                  value: _ft,
                                ))),
                        Container(
                            width: MediaQuery.of(context).size.width * .4,
                            child: Inch(
                              validator: (val) {
                                if (val == null) {
                                  return "Please choose their height";
                                }
                              },
                              onChanged: (String val) {
                                log.i('Pressed inch field');
                                setState(() {
                                  _in = val;
                                });
                              },
                              value: _in,
                            )),
                      ],
                    ),
                  ])),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .0225),
                      child: RaisedRoundedGradientButton(
                          child: Text(
                              userFound == true ? 'Update Info' : 'Submit Info',
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor)),
                          onPressed: () {
                            log.i('Submit button for who section pressed');
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            currentDate.who.phone_number = phone_number;
                            currentDate.who.first_name = _firstName;
                            currentDate.who.last_name = _lastName;
                            currentDate.who.sex = _sex;
                            currentDate.who.race = _race;
                            currentDate.who.eye = _eye;
                            currentDate.who.hair = _hair;
                            currentDate.who.ft = _ft;
                            currentDate.who.inch = _in;
                            currentDate.who.temp = 'true';
                            print('FIRST NAME');
                            print(currentDate.who.first_name);
                            log.d('dateProvdier.setRecentDate');
                            dateProvider.setRecentDate(currentDate);
                            if (userFound = true) {
                              log.d('Updated user');
                              CustomToast.showDialog(
                                  'Updated user', context, Toast.BOTTOM);
                            } else {
                              log.d('Created user');
                              CustomToast.showDialog(
                                  'Created user', context, Toast.BOTTOM);
                            }
                          }))
                ]),
              ));
            }));
  }
}
