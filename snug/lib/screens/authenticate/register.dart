import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';

import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';
import 'package:snug/providers/LogProvider.dart';

import 'package:snug/screens/authenticate/sign_in.dart';
import 'package:snug/screens/otp/otp.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';
import 'package:toast/toast.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Emoji somethingWentWrong = Emoji.byChar(Emojis.flushedFace);

  final TextEditingController _passOne = TextEditingController();
  final TextEditingController _passTwo = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool didPressRegister = false;

  //text field state
  String phonenumber = '';
  String password1 = '';
  String password2 = '';
  String error = '';
  bool checkPrivacyPolicy = false;
  bool checkEULA = false;
  //final log = getLogger('Register');
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Register', logProvider.getLogPath);
    final consoleLog = getConsoleLogger('Register');

    return WillPopScope(
      onWillPop: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignIn())),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            leading: new IconButton(
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).colorScheme.secondaryVariant,
              onPressed: () {
                log.i('pushToSignIn');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
            ),
            backgroundColor: Colors.transparent,
          ),
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Center(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 60, right: 36.0, left: 36.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  height: 155.0,
                                  child: Image.asset(
                                    'assets/image/logo1.png',
                                    fit: BoxFit.contain,
                                  )),
                              Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      TextFormField(
                                        onEditingComplete: () =>
                                            node.nextFocus(),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp('[0-9]+')),
                                        ],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                            icon: Icon(
                                              Icons.phone,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant,
                                            ),
                                            labelText: 'Phone Number'),
                                        validator: (String val) {
                                          if (val.length != 10) {
                                            return "Please enter a valid phone number";
                                          }
                                        },
                                        onChanged: (val) {
                                          setState(() => phonenumber = val);
                                        },
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      TextFormField(
                                        controller: _passOne,
                                        onEditingComplete: () =>
                                            node.nextFocus(),
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                            icon: Icon(
                                              Icons.security,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant,
                                            ),
                                            labelText: 'Password'),
                                        validator: (val) => val.length < 6
                                            ? 'Enter a password 6+ char long'
                                            : null,
                                        obscureText: true,
                                        onChanged: (val) {
                                          setState(() => password1 = val);
                                        },
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      TextFormField(
                                        controller: _passTwo,
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                            icon: Icon(
                                              Icons.security,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant,
                                            ),
                                            labelText: 'Confirm Password'),
                                        validator: (String val) {
                                          if (val != _passOne.text) {
                                            return "Passwords do not match";
                                          }
                                        },
                                        obscureText: true,
                                        onChanged: (val) {
                                          setState(() => password2 = val);
                                        },
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 25,
                                          ),
                                          Checkbox(
                                              value: this.checkPrivacyPolicy,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  this.checkPrivacyPolicy =
                                                      value;
                                                });
                                              }),
                                          ParsedText(
                                              selectable: false,
                                              alignment: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                              text:
                                                  "Agree to our Privacy Policy",
                                              parse: <MatchText>[
                                                MatchText(
                                                  type: ParsedType.CUSTOM,
                                                  pattern: r"Privacy Policy",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryVariant),
                                                  onTap: (url) async {
                                                    //log.i('openPrivacyPolicy');
                                                    const privacyPolicyUrl =
                                                        "https://upineapps.com/snug-privacy-policy";
                                                    try {
                                                      if (await canLaunch(
                                                          privacyPolicyUrl)) {
                                                        log.i(
                                                            'didLaunchPrivacyPolicy');
                                                        await launch(
                                                            privacyPolicyUrl);
                                                      } else {
                                                        throw "Can't launch url";
                                                      }
                                                    } catch (e) {
                                                      log.e(e);
                                                      CustomToast.showDialog(
                                                          'Failed to open privacy policy. Please try again later.',
                                                          context,
                                                          Toast.BOTTOM);
                                                    }
                                                  },
                                                ),
                                              ])
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 25,
                                          ),
                                          Checkbox(
                                              // checkColor: Theme.of(context)
                                              //     .colorScheme
                                              //     .secondaryVariant,
                                              value: this.checkEULA,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  this.checkEULA = value;
                                                });
                                              }),
                                          ParsedText(
                                              selectable: false,
                                              alignment: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                              text:
                                                  "Agree to our Terms and Conditions",
                                              parse: <MatchText>[
                                                MatchText(
                                                  type: ParsedType.CUSTOM,
                                                  pattern:
                                                      r"Terms and Conditions",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryVariant),
                                                  onTap: (url) async {
                                                    //log.i('openEULA');
                                                    const eulaUrl =
                                                        "https://upineapps.com/snug-eula";
                                                    try {
                                                      if (await canLaunch(
                                                          eulaUrl)) {
                                                        log.i('didLaunchEULA');
                                                        await launch(eulaUrl);
                                                      } else {
                                                        throw "Can't launch url";
                                                      }
                                                    } catch (e) {
                                                      log.e(e);
                                                      CustomToast.showDialog(
                                                          'Failed to open EULA. Please try again later.',
                                                          context,
                                                          Toast.BOTTOM);
                                                    }
                                                  },
                                                ),
                                              ]),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        child: RaisedRoundedGradientButton(
                                          child: didPressRegister == true
                                              ? SizedBox(
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .secondary),
                                                  ),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .025,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .05)
                                              : Text(
                                                  'Register',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                          onPressed: () async {
                                            if (didPressRegister == false) {
                                              //fixes double tap issue
                                              log.i('didPressRegister');
                                              setState(() {
                                                didPressRegister = true;
                                              });
                                              if (_formKey.currentState
                                                  .validate()) {
                                                if (this.checkEULA == true &&
                                                    this.checkPrivacyPolicy ==
                                                        true) {
                                                  try {
                                                    log.i(
                                                        'CognitoService.registerUser');
                                                    Map<String, Object>
                                                        registerUserResult =
                                                        await CognitoService
                                                            .instance
                                                            .registerUser(
                                                                phonenumber,
                                                                password2);
                                                    log.d(
                                                        'registerUserResult: ${registerUserResult['status']}');
                                                    if (registerUserResult[
                                                            'status'] ==
                                                        true) {
                                                      log.i(
                                                          'SharedPreferences.setString: phonenumber: $phonenumber');
                                                      SharedPreferences
                                                          _profile =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      _profile.setString(
                                                          'phonenumber',
                                                          phonenumber);
                                                      log.i('pushToOTP');
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Otp(
                                                                      phonenumber:
                                                                          phonenumber,
                                                                      password:
                                                                          password2,
                                                                    )),
                                                      );
                                                    } else {
                                                      log.e(
                                                          'registerUserResult[status] = false');
                                                      log.e(
                                                          'Shouldn\'t have gotten here');
                                                      throw Error;
                                                    }
                                                  } catch (e) {
                                                    log.e(
                                                        'Registration failed');
                                                    log.e(e);
                                                    CustomToast.showDialog(
                                                        'Registration failed. Do you already have an account?',
                                                        context,
                                                        Toast.BOTTOM);
                                                    log.i(
                                                        'Waiting 2 seconds for Toast to disappear and allowing register button press again');
                                                    await Future.delayed(
                                                        Duration(seconds: 2),
                                                        () {
                                                      setState(() {
                                                        didPressRegister =
                                                            false;
                                                      });
                                                    });
                                                  }
                                                } else {
                                                  log.i(
                                                      'Didn\'t accept privacy and/or EULA');
                                                  CustomToast.showDialog(
                                                      'You must accept the privacy policy and the EULA to use the Snug app',
                                                      context,
                                                      Toast.BOTTOM);
                                                }
                                              } else {
                                                log.i(
                                                    'Waiting 2 seconds and allowing register button press again');
                                                await Future.delayed(
                                                    Duration(seconds: 2), () {
                                                  setState(() {
                                                    didPressRegister = false;
                                                  });
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ))
                            ])))),
          )),
    );
  }
}
