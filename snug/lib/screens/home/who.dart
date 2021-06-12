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
import 'package:snug/services/remote_db_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:toast/toast.dart';

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

  final log = getLogger('addDate: who');
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

  findUser(DateProvider dateProvider) async {
    setState(() {
      triedToFindUser = true;
    });

    try {
      //only returning the registered user not a reported user
      dynamic result = await RemoteDatabaseHelper.instance
          .getRegisteredUserByPhone(phone_number);

      if (result['status'] == true) {
        User userResult = User.fromMap(result['data']);

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
        dateProvider.setRecentDate(currentDate);

        setState(() {
          userFound = true;
        });

        CustomToast.showDialog('Does the user info look right?', context);
      } else {
        //user not found in database

        CustomToast.showDialog('Couldn\'t find user', context);
        _phoneController.text = phone_number;
      }
    } catch (e) {
      CustomToast.showDialog(
          'Error finding user. Please try later!', context); //add emoji :'(
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    final dateProvider = Provider.of<DateProvider>(context, listen: false);

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
                    )),
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .05),
                        child: Container(
                            child: RaisedRoundedGradientButton(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Text('Check for user',
                                    style: TextStyle(
                                        color: Theme.of(context).dividerColor)),
                                onPressed: () async {
                                  if (_whoFormKey.currentState.validate()) {
                                    findUser(
                                        dateProvider); //first thing is find user
                                  }
                                }))),
                  ]),
                ))
              ]);
            },
            fallbackBuilder: (BuildContext context) {
              return Container(
                  height: MediaQuery.of(context).size.height * .5,
                  child: Form(
                    key: _whoFormKey1,
                    child: Column(children: <Widget>[
                      Container(
                          height: MediaQuery.of(context).size.height * .083,
                          child: TextFormField(
                            enabled: false,
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
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
                                      right: MediaQuery.of(context).size.width *
                                          .1),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: TextFormField(
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
                                    ),
                                  )),
                              Container(
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: TextFormField(
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
                                    right:
                                        MediaQuery.of(context).size.width * .1),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: Eye(
                                      validator: (val) {
                                        if (val == null) {
                                          return "Please choose their eye color.";
                                        }
                                      },
                                      onChanged: (String val) {
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
                                    setState(() {
                                      _hair = val;
                                    });
                                  },
                                  value: _hair,
                                )),
                          ],
                        ),
                      ])),
                      // Container(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //       "Height",
                      //       style: TextStyle(
                      //           fontSize: 16,
                      //           color: Theme.of(context).brightness ==
                      //                   Brightness.dark
                      //               ? Colors.white
                      //               : Colors.black54),
                      //     )),
                      Container(
                          child: Column(children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).size.width * .1),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: Feet(
                                      validator: (val) {
                                        if (val == null) {
                                          return "Please choose their height";
                                        }
                                      },
                                      onChanged: (String val) {
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
                                  userFound == true
                                      ? 'Update Info'
                                      : 'Submit Info',
                                  style: TextStyle(
                                      color: Theme.of(context).dividerColor)),
                              onPressed: () {
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
                                dateProvider.setRecentDate(currentDate);
                                if (userFound = true) {
                                  CustomToast.showDialog(
                                      'Updated user', context);
                                } else {
                                  CustomToast.showDialog(
                                      'Created user', context);
                                }
                              }))
                    ]),
                  ));
            }));
  }
}
