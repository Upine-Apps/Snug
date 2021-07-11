import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';

import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';

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
  //text field state
  String phonenumber = '';
  String password1 = '';
  String password2 = '';
  String error = '';
  bool checkPrivacyPolicy = false;
  bool checkEULA = false;
  final log = getLogger('Register');
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

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
                                          log.i('setPhoneNumber | $val');
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
                                          log.i('setPassword | ****');
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
                                                    log.i('openPrivacyPolicy');
                                                    const privacyPolicyUrl =
                                                        "https://upineapps.com/snug-privacy-policy";
                                                    try {
                                                      if (await canLaunch(
                                                          privacyPolicyUrl)) {
                                                        await launch(
                                                            privacyPolicyUrl);
                                                      } else {
                                                        throw "Can't launch url";
                                                      }
                                                    } catch (e) {
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
                                                    log.i('openEULA');
                                                    const eulaUrl =
                                                        "https://upineapps.com/snug-eula";
                                                    try {
                                                      if (await canLaunch(
                                                          eulaUrl)) {
                                                        await launch(eulaUrl);
                                                      } else {
                                                        throw "Can't launch url";
                                                      }
                                                    } catch (e) {
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
                                          child: Text(
                                            'Register',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .dividerColor),
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              if (this.checkEULA == true &&
                                                  this.checkPrivacyPolicy ==
                                                      true) {
                                                try {
                                                  Map<String, Object> result =
                                                      await CognitoService
                                                          .instance
                                                          .registerUser(
                                                              phonenumber,
                                                              password2);
                                                  if (result['status'] ==
                                                      false) {
                                                    if (result['message'] ==
                                                        'ERROR') {
                                                      CustomToast.showDialog(
                                                          'Something went wrong, please try again. $somethingWentWrong',
                                                          context,
                                                          Toast.BOTTOM);
                                                    } else if (result[
                                                            'message'] ==
                                                        'REGISTRATION_FAILED') {
                                                      CustomToast.showDialog(
                                                          'Registration failed, please try again later. $somethingWentWrong',
                                                          context,
                                                          Toast.BOTTOM);
                                                      //toast to say registration failed and give reason
                                                      //LOOK INTO THE POSSIBLE REASONS AND RETURN FROM THE COGNITO SERVICE CLASS
                                                    }
                                                  } else if (result['status'] ==
                                                      true) {
                                                    SharedPreferences _profile =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    _profile.setString(
                                                        'phonenumber',
                                                        phonenumber);

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Otp(
                                                                phonenumber:
                                                                    phonenumber,
                                                                password:
                                                                    password2,
                                                              )),
                                                    );
                                                  }
                                                } catch (e) {
                                                  log.d('registration error');
                                                  log.e(e);
                                                }
                                              } else {
                                                CustomToast.showDialog(
                                                    'You must accept the privacy policy and the EULA to use the Snug app',
                                                    context,
                                                    Toast.BOTTOM);
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
