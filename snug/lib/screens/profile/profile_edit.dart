import 'dart:async';
import 'dart:ui' as ui;
import 'package:emojis/emoji.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snug/core/errors/UpdateUserException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/eye.dart';
import 'package:snug/custom_widgets/feet.dart';
import 'package:snug/custom_widgets/fifty_states.dart';
import 'package:snug/custom_widgets/hair.dart';
import 'package:snug/custom_widgets/inch.dart';

import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/LogProvider.dart';
import 'package:snug/providers/UserProvider.dart';

import 'package:snug/services/remote_db_service.dart';

import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  TextEditingController _cityController;
  final _formKey = GlobalKey<FormState>();
  String _eye;
  String _hair;
  String _ft;
  String _in;
  String _state;
  Emoji somethingWentWrong = Emoji.byChar(Emojis.flushedFace);
  var _profileEditKey = GlobalKey<FormState>();
  bool didPressSave = false;
  User tempUser = new User();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Profile Edit', logProvider.getLogPath);
    final consoleLog = getConsoleLogger('Profile Edit');
    final _user = Provider.of<UserProvider>(context, listen: true);
    tempUser.uid = _user.getUser.uid;

    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        backgroundColor: Colors.transparent,
        // insetPadding: EdgeInsets.all(36),
        contentPadding: EdgeInsets.all(0),
        content: Container(
            width: MediaQuery.of(context).size.width,
            //height: MediaQuery.of(context).size.height * .7,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/image/profile_dark_background.png'
                            : 'assets/image/profile_light_background.png'),
                    fit: BoxFit.fill)),
            child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Form(
                  key: _profileEditKey,
                  child: Column(children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * .1),
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .05,
                          right: MediaQuery.of(context).size.width * .05),
                      alignment: Alignment.centerLeft,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: Eye(
                                  onChanged: (String val) {
                                    log.i('Tapped on eye field');
                                    tempUser.eye = val;
                                    setState(() {
                                      _eye = val;
                                    });
                                  },
                                  value: _eye,
                                )),
                            Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: Hair(
                                    onChanged: (String val) {
                                      log.i('Tapped on hair field');
                                      tempUser.hair = val;
                                      setState(() {
                                        _hair = val;
                                      });
                                    },
                                    value: _hair)),
                          ]),
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .05,
                            right: MediaQuery.of(context).size.width * .05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: Feet(
                                    onChanged: (String val) {
                                      log.i('Tapped on feet field');
                                      tempUser.ft = val;
                                      setState(() {
                                        _ft = val;
                                      });
                                    },
                                    value: _ft)),
                            Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: Inch(
                                    onChanged: (String val) {
                                      log.i('Tapped on inch field');
                                      tempUser.inch = val;
                                      setState(() {
                                        _in = val;
                                      });
                                    },
                                    value: _in))
                          ],
                        )),
                    Container(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .05,
                            right: MediaQuery.of(context).size.width * .05),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (String val) {
                                    if (val.length > 0 && val.length != 5) {
                                      return "Enter a valid zip code";
                                    }
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]+')),
                                  ],
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryVariant),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    labelText: 'Zip',
                                  ),
                                  onChanged: (val) {
                                    tempUser.zip = val;
                                  },
                                  onTap: () {
                                    log.i('Tapped on zip field');
                                  },
                                ),
                              ),
                            ])),
                    Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: RaisedRoundedGradientButton(
                            child: didPressSave == true
                                ? SizedBox(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    height: MediaQuery.of(context).size.height *
                                        .025,
                                    width:
                                        MediaQuery.of(context).size.width * .05)
                                : Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Theme.of(context).dividerColor),
                                  ),
                            onPressed: () async {
                              log.i('Save Profile Edit fields');
                              if (didPressSave == false) {
                                log.i('didPressSave');
                                consoleLog.i('didPressSave');
                                setState(() {
                                  didPressSave = true;
                                });
                                if (_profileEditKey.currentState.validate()) {
                                  _user.editUser(tempUser);
                                  try {
                                    log.i(
                                        'RemoteDatebaseHelper.instance.updateUser');
                                    dynamic result = await RemoteDatabaseHelper
                                        .instance
                                        .updateUser(
                                            _user.getUser, tempUser.uid);
                                    if (result['status'] == true) {
                                      log.d('Successfully updated user');
                                      Navigator.pop(context);
                                    } else {
                                      throw UpdateUserException(
                                          'Failed to update the user');
                                    }
                                  } catch (e) {
                                    log.e('Failed to update user. Error: $e');
                                    CustomToast.showDialog(
                                        'Failed to update profile! Please try again later $somethingWentWrong',
                                        context,
                                        Toast.BOTTOM);
                                    log.d(
                                        'Waiting 2 seconds for Toast to disappear and allowing save button again');
                                    await Future.delayed(Duration(seconds: 2),
                                        () {
                                      setState(() {
                                        didPressSave = false;
                                      });
                                    });
                                  }
                                } else {
                                  log.d(
                                      'Waiting 2 seconds and allowing save button again');
                                  await Future.delayed(Duration(seconds: 2),
                                      () {
                                    setState(() {
                                      didPressSave = false;
                                    });
                                  });
                                }
                              }
                            })),
                  ]),
                ))));
  }
}
