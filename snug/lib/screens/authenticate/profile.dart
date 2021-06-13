import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snug/core/errors/AddUserAttributeException.dart';
import 'package:snug/core/errors/AddUserException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/eye.dart';
import 'package:snug/custom_widgets/feet.dart';
import 'package:snug/custom_widgets/gender.dart';
import 'package:snug/custom_widgets/hair.dart';
import 'package:snug/custom_widgets/inch.dart';
import 'package:snug/custom_widgets/race.dart';

import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/providers/walkthrough/walkthrough.dart';

import 'package:snug/screens/sync/sync.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/services/remote_db_service.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';

class Profile extends StatefulWidget {
  final Function toggleView;
  final String phonenumber;
  final CognitoUser cognitoUser;
  Profile({Key key, this.toggleView, this.phonenumber, this.cognitoUser})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Emoji somethingWentWrong = Emoji.byChar(Emojis.flushedFace);
  User tempUser = new User();

  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _controller1 = TextEditingController();

  //text field state
  String first_name = '';
  String last_name = '';

  String error = '';
  String _sex;
  String _race;
  String _eye;
  String _hair;
  String height = '';
  String trusted_1 = '';
  String trusted_2 = '';
  String trusted_3 = '';
  String _ft;
  String _in;
  String _month;
  String _day;
  String _year;
  String _dob = 'Date of Birth';
  String _zip;

  final log = getLogger('CreateProfile');

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    final _userProvider = Provider.of<UserProvider>(context, listen: true);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary
                  ])),
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * .01,
                  horizontal: MediaQuery.of(context).size.width * .05),
              child: Container(
                  child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          Header(
                              child: Image.asset('assets/image/logo1.png',
                                  fit: BoxFit.contain, height: 50)),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .05,
                          ),
                          Container(
                              child: Text('Let\'s get that profile set up!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant,
                                  ))),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .075,
                          ),
                          TextFormField(
                            validator: (String val) {
                              if (val.length > 30) {
                                return "Ya got a shorter first name?";
                              } else if (val.length == 0) {
                                return "What's your first name?";
                              }
                            },
                            onEditingComplete: () => node.nextFocus(),
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                            controller: _controller,
                            decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelText: 'First Name'),
                            onChanged: (val) {
                              log.i('setFirstName | $val');
                              tempUser.first_name = val;
                              setState(() => first_name = val);
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            validator: (String val) {
                              if (val.length > 30) {
                                return "Ya got a shorter last name?";
                              } else if (val.length == 0) {
                                return "What's your last name?";
                              }
                            },
                            onEditingComplete: () => node.nextFocus(),
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                            decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelText: 'Last Name'),
                            onChanged: (val) {
                              log.i('setLastName | $val');
                              tempUser.last_name = val;
                              setState(() => last_name = val);
                            },
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              DateTime date = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      DateTime(DateTime.now().year - 100),
                                  lastDate: DateTime(DateTime.now().year,
                                      DateTime.now().month, DateTime.now().day),
                                  initialDate: DateTime.now());
                              _dob = '${date.month}/${date.day}/${date.year}';

                              tempUser.dob = _dob;
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  child: Text('$_dob',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).hintColor)),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryVariant,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Divider(
                              thickness: 1,
                              color: Theme.of(context).primaryColor),
                          Gender(
                            validator: (val) {
                              if (val == null) {
                                return "Please choose your sex";
                              }
                            },
                            onChanged: (val) {
                              log.i('setSex | $val');
                              tempUser.sex = val;
                              setState(() {
                                _sex = val;
                              });
                            },
                            value: _sex,
                          ),
                          Race(
                            validator: (val) {
                              if (val == null) {
                                return "Please choose your race.";
                              }
                            },
                            onChanged: (val) {
                              log.i('setRace | $val');
                              tempUser.race = val;
                              setState(() {
                                _race = val;
                              });
                            },
                            value: _race,
                          ),
                          Eye(
                            validator: (val) {
                              if (val == null) {
                                return "Please choose your eye color.";
                              }
                            },
                            onChanged: (val) {
                              log.i('setEye | $val');
                              tempUser.eye = val;
                              setState(() {
                                _eye = val;
                              });
                            },
                            value: _eye,
                          ),
                          Hair(
                            validator: (val) {
                              if (val == null) {
                                return "Please choose your hair color";
                              }
                            },
                            onChanged: (val) {
                              log.i('setHair | $val');
                              tempUser.hair = val;
                              setState(() {
                                _hair = val;
                              });
                            },
                            value: _hair,
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          Text(
                            'Height:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  width: MediaQuery.of(context).size.width *
                                      (.9 / 2),
                                  child: Feet(
                                    validator: (val) {
                                      if (val == null) {
                                        return "Please choose your height";
                                      }
                                    },
                                    onChanged: (val) {
                                      log.i('setFt | $val');
                                      tempUser.ft = val;
                                      setState(() {
                                        _ft = val;
                                      });
                                    },
                                    value: _ft,
                                  )),
                              Container(
                                  width: MediaQuery.of(context).size.width *
                                      (.9 / 2),
                                  child: Inch(
                                    validator: (val) {
                                      if (val == null) {
                                        return "Please choose your height";
                                      }
                                    },
                                    onChanged: (val) {
                                      log.i('setInches | $val');
                                      tempUser.inch = val;
                                      setState(() {
                                        _in = val;
                                      });
                                    },
                                    value: _in,
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * (.9),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: (String val) {
                                      if (val.length != 5) {
                                        return "Please enter a valid zip code";
                                      } else if (val.length == 0) {
                                        return "What's your zip code?";
                                      }
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]+')),
                                    ],
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryVariant),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        labelText: 'Zip Code'),
                                    onChanged: (val) {
                                      log.i('setZip | $val');
                                      tempUser.zip = val;
                                      setState(() => _zip = val);
                                    },
                                  ),
                                )
                              ]),
                          SizedBox(
                            height: 25.0,
                          ),
                          RaisedRoundedGradientButton(
                            width: MediaQuery.of(context).size.width * .25,
                            child: Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              // print(height);
//DO ERROR HANDLING HERE
//NEED TO CHECK IF ALL THE THINGS HAVE BEEN FILLED OUT

                              if (_dob == 'Date of Birth') {
                                CustomToast.showDialog(
                                    'Please enter your date of birth', context);
                              } else if (_formKey.currentState.validate()) {
                                log.i('convertHeight | _ft: $_ft _in: $_in');
                                // Convert height into a total of inches for data base.
                                var ft1 = int.parse(_ft);
                                var in1 = int.parse(_in);
                                var h = (ft1 * 12) + in1;
                                // Convert height into a total of inches for data base.
                                log.d('Height: $h');
                                height =
                                    '$h'; //pretty sure we aren't even doing anything with this variable
                                // tempUser.phone_number = '1111111111';
                                tempUser.temp = 'false';
                                tempUser.phone_number = widget.phonenumber;
                                tempUser.legal = 'true';
                                //UNCOMMENT THIS WHEN DONE TESTING ^^^^^
                                try {
                                  dynamic result = await RemoteDatabaseHelper
                                      .instance
                                      .addUser(tempUser);
                                  if (result['status'] == true) {
                                    var user_id = result['user_id'].toString();
                                    SharedPreferences profile =
                                        await SharedPreferences.getInstance();

                                    profile.setString('uid', user_id);
                                    profile.setString(
                                        'first_name', tempUser.first_name);
                                    _userProvider.editUser(tempUser);
                                    Map<String, Object> attributeUpdated =
                                        await CognitoService.instance
                                            .addUserAttributes(
                                                widget.cognitoUser, user_id);
                                    if (attributeUpdated['status'] == true) {
                                      log.i('pushToMainPage');
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Walkthrough()),
                                      );
                                    } else {
                                      throw AddUserAttributeException(
                                          'Failed to add user attribute');
                                    }
                                  } else {
                                    throw AddUserException(
                                        'Failed to add the user');
                                  }
                                } catch (e) {
                                  log.e(
                                      'Failed to add user profile. Error: $e');
                                  CustomToast.showDialog(
                                      'Looks like we ran into an error. Please try again later! $somethingWentWrong',
                                      context);
                                }
                              }
                            },
                          )
                        ],
                      ))))),
    );
  }
}
