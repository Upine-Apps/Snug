import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:snug/providers/LogProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/profile.dart';
import 'package:toast/toast.dart';
import 'package:snug/screens/authenticate/register.dart';
import 'package:snug/screens/otp/otp.dart';
import 'package:snug/screens/sync/sync.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import 'forgot_password.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FocusNode myFocusNode = new FocusNode();
  var _formKey = GlobalKey<FormState>();
  bool didPressLogin = false;
  String phonenumber = '';
  String password = '';
  String fname = '';
  Directory directory;

  final userPool =
      CognitoUserPool('us-east-2_rweyLTmso', '26gd072a3jrqsjubrmaj0r4nr3');

  @override
  void initState() {
    super.initState();
    // getPath().then((Directory val) {
    //   print(val.path);
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getInfo(context);
    });
    myFocusNode.addListener(() {
      print("Has focus: ${myFocusNode.hasFocus}");
    });
  }

  final TextEditingController _controller = TextEditingController();
  Future<void> getInfo(BuildContext context) async {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final logPath = prefs.getString('path');
    logProvider.setLogPath(logPath);
    final _savedPhoneNumber = prefs.getString('phonenumber');

    setState(() {
      fname = prefs.getString('first_name');
      if (_savedPhoneNumber != null) {
        _controller.text = _savedPhoneNumber;
        phonenumber = _savedPhoneNumber;
        fname = prefs.getString('first_name');
        print(_controller.text);
      } else {
        _controller.text = null;
      }
    });
  }

  displayName() {
    if (fname != null) {
      return Text('Welcome Back, $fname!');
    } else {
      return Text('Welcome!');
    }
  }

  // Future<Directory> getPath() async {
  //   Directory dir = await getExternalStorageDirectory();
  //   setState(() {
  //     directory = dir;
  //   });
  //   print(dir);
  //   return dir;
  // }

  @override
  Widget build(BuildContext context) {
    final _userProvider = Provider.of<UserProvider>(context, listen: true);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    // logProvider.setLogPath(directory);
    final node = FocusScope.of(context);
    final log = getLogger('SignIn', logProvider.getLogPath);
    final consoleLog = getConsoleLogger('SignIn');
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 100, right: 36.0, left: 36.0),
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
                          Container(child: displayName()),
                          Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    onEditingComplete: () => node.nextFocus(),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]+')),
                                    ],
                                    controller: _controller,
                                    focusNode: myFocusNode,
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
                                      labelText: 'Phone Number',
                                      labelStyle: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 16.0),
                                    ),
                                    validator: (String val) {
                                      if (val.length != 10) {
                                        return "Please enter a valid Phone Number";
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
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.security,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 16.0),
                                    ),
                                    obscureText: true,
                                    onChanged: (val) {
                                      setState(() => password = val);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  RaisedRoundedGradientButton(
                                      //check button size

                                      child: didPressLogin == true
                                          ? SizedBox(
                                              child: CircularProgressIndicator(
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
                                              'Login',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                      onPressed: () async {
                                        if (didPressLogin == false) {
                                          //fixes double tap issue
                                          log.i('didPressLogin');
                                          setState(() {
                                            didPressLogin = true;
                                          });
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());

                                          if (_formKey.currentState
                                              .validate()) {
                                            try {
                                              log.i(
                                                  'CognitoService.signInUser');
                                              Map<String, Object>
                                                  signInUserResult =
                                                  await CognitoService.instance
                                                      .signInUser(
                                                          '+1$phonenumber',
                                                          password);
                                              log.d(
                                                  'signInUserResult: ${signInUserResult['status']}');
                                              if (signInUserResult['status'] ==
                                                  true) {
                                                log.d(
                                                    'cognitoUser: ${signInUserResult['cognitoUser']}');
                                                log.d(
                                                    'cognitoSession: ${signInUserResult['cognitoSession']}');
                                                //dont need OTP
                                                CognitoUser confirmedUser =
                                                    signInUserResult[
                                                        'cognitoUser'];
                                                CognitoUserSession userSession =
                                                    signInUserResult[
                                                        'cognitoSession'];
                                                log.i(
                                                    'userProvider.setCognitoUser');
                                                _userProvider.setCognitoUser(
                                                    confirmedUser);
                                                log.i(
                                                    'userProvider.setUserSession');
                                                _userProvider.setUserSession(
                                                    userSession);
                                                try {
                                                  log.i(
                                                      'CognitoService.getUserAttributes');
                                                  Map<String, Object>
                                                      getAttributesResult =
                                                      await CognitoService
                                                          .instance
                                                          .getUserAttributes(
                                                              confirmedUser);
                                                  log.d(
                                                      'getAttributesResult: ${getAttributesResult['status']}');
                                                  if (getAttributesResult[
                                                          'status'] ==
                                                      true) {
                                                    String user_id =
                                                        getAttributesResult[
                                                            'data'];
                                                    log.i(
                                                        'SharedPreferences.setString: uid: ${user_id} phonenumber: ${phonenumber}');
                                                    SharedPreferences _profile =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    _profile.setString(
                                                        'uid', user_id);
                                                    _profile.setString(
                                                        'phonenumber',
                                                        phonenumber);
                                                    log.i('pushToMainPage');
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SyncScreen()),
                                                    );
                                                  }
                                                } catch (e) {
                                                  log.e(e);
                                                  log.i(
                                                      'pushToProfileCreation');
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Profile(
                                                              phonenumber:
                                                                  phonenumber,
                                                              cognitoUser:
                                                                  confirmedUser),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                log.e(
                                                    'signInUserResult[status] = false');
                                                log.e(
                                                    'Shouldn\'t have gotten here');
                                                throw Error;
                                              }
                                            } on CognitoClientException catch (e) {
                                              log.e(e);
                                              consoleLog.e(e);
                                              if (e.code ==
                                                  'UserNotConfirmedException') {
                                                log.e('OTP needed');
                                                log.i(
                                                    'CognitoService.resendCode');
                                                CognitoService.instance
                                                    .resendCode(
                                                        phonenumber, password);
                                                log.i('pushToOTP');
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Otp(
                                                      phonenumber: phonenumber,
                                                      password: password,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                log.e(
                                                    'Incorrect phone number or password');
                                                CustomToast.showDialog(
                                                    'Incorrect phone number or password',
                                                    context,
                                                    Toast.BOTTOM);
                                                log.i(
                                                    'Waiting 2 seconds for Toast to disappear and allowing sign in button press again');
                                                await Future.delayed(
                                                    Duration(seconds: 2), () {
                                                  setState(() {
                                                    didPressLogin = false;
                                                  });
                                                });
                                              }
                                            } on CognitoUserMfaRequiredException catch (e) {
                                              log.e('MFA Needed');
                                              log.i(
                                                  'CognitoService.resendCode');
                                              CognitoService.instance
                                                  .resendCode(
                                                      phonenumber, password);
                                              log.i('pushToOTP');
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Otp(
                                                    phonenumber: phonenumber,
                                                    password: password,
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              log.e(e);
                                              CustomToast.showDialog(
                                                  'Something went wrong',
                                                  context,
                                                  Toast.BOTTOM);
                                              log.i(
                                                  'Waiting 2 seconds for Toast to disappear and allowing sign in button press again');
                                              await Future.delayed(
                                                  Duration(seconds: 2), () {
                                                setState(() {
                                                  didPressLogin = false;
                                                });
                                              });
                                            }
                                          } else {
                                            log.i(
                                                'Waiting 2 seconds for Toast to disappear and allowing sign in button press again');
                                            await Future.delayed(
                                                Duration(seconds: 2), () {
                                              setState(() {
                                                didPressLogin = false;
                                              });
                                            });
                                          }
                                        }
                                      }),
                                  Padding(
                                    padding: EdgeInsets.only(top: 25),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                          ),
                                          onPressed: () {
                                            log.i('pushToForgotPassword');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ForgotPassword()),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          'Dont Have An Account?',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        TextButton(
                                          child: Text(
                                            'Sign Up!',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryVariant),
                                          ),
                                          onPressed: () {
                                            log.i('pushToRegister');
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Register()),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ),
                    )))),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }
}
