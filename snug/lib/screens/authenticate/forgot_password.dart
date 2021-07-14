import 'dart:async';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';
import 'package:snug/providers/LogProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/authenticate/sign_in.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:toast/toast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String _otpone;
  String _otptwo;
  String _otpthree;
  String _otpfour;
  String _otpfive;
  String _otpsix;
  String _otp;
  bool didPressSubmit = false;
  String password1 = '';
  String password2 = '';
  String currentText = "";
  final TextEditingController _passOne = TextEditingController();
  final TextEditingController _passTwo = TextEditingController();
  TextEditingController textEditingController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType> errorController;
  @override
  void initState() {
    super.initState;
    errorController = StreamController<ErrorAnimationType>();
    // checkForCode();
  }

  // checkForCode() async {
  //   await SmsAutoFill().listenForCode;
  // }

  String _otpCode = '';
  String phoneNumber;
  bool gotPhoneNumber = false;

  CognitoUser cognitoUser;
  var _formKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  //final log = getLogger('forgotPassword');
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('ForgotPassword', logProvider.getLogPath);
    final consoleLog = getConsoleLogger('ForgotPassword');

    return WillPopScope(
      onWillPop: () {
        log.i('pushToAuthenticate');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Authenticate()));
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
              automaticallyImplyLeading:
                  false, // Removes default back button on app bar
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.secondaryVariant),
                    onPressed: () {
                      log.i('pushToAuthenticate');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Authenticate()),
                      );
                    },
                  ),
                  gotPhoneNumber == false
                      ? Text('')
                      : TextButton(
                          onPressed: () async {
                            try {
                              log.i('CognitoService.forgotPassword');
                              Map<String, Object> forgotPasswordResponse =
                                  await CognitoService.instance
                                      .forgotPassword("+1$phoneNumber");
                              log.d(
                                  'forgotPasswordResponse: ${forgotPasswordResponse['status']}');
                              if (forgotPasswordResponse['status'] == true) {
                                log.d(
                                    'cognitoUser: ${forgotPasswordResponse['cognitoUser']}');
                                setState(() {
                                  cognitoUser =
                                      forgotPasswordResponse['cognitoUser'];
                                });
                              }
                            } on CognitoClientException catch (e) {
                              if (e.code == 'LimitExceededException') {
                                log.e(e);
                                CustomToast.showDialog(
                                    'Too many password reset attempts. Please wait a bit and try again.',
                                    context,
                                    Toast.BOTTOM);
                                log.i(
                                    'Waiting 2 seconds for Toast to disappear and pushing to Authenticate');
                                await Future.delayed(Duration(seconds: 2), () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Authenticate()),
                                  );
                                });
                              }
                            } catch (e) {
                              log.e(e);
                              CustomToast.showDialog(
                                  'Failed to resend OTP code. Please check your texts for the original code',
                                  context,
                                  Toast.BOTTOM);
                            }
                          },
                          child: Text(
                            'Resend Code',
                            style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 16),
                          ))
                ],
              )),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 100,
                        right: MediaQuery.of(context).size.width * .1,
                        left: MediaQuery.of(context).size.width * .1),
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
                            child: Column(children: <Widget>[
                              Conditional.single(
                                  context: context,
                                  conditionBuilder: (BuildContext context) =>
                                      gotPhoneNumber == false,
                                  widgetBuilder: (BuildContext context) {
                                    return Column(
                                      children: <Widget>[
                                        Container(
                                          child: Form(
                                            key: _phoneFormKey,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                    child: TextFormField(
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp('[0-9]+')),
                                                  ],
                                                  validator: (String val) {
                                                    if (val.length != 10) {
                                                      return "Please enter a valid Phone Number";
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                      errorStyle: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .secondaryVariant),
                                                      enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor)),
                                                      labelText:
                                                          'Phone Number'),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      phoneNumber = val;
                                                    });
                                                  },
                                                )),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .05),
                                                  child: Container(
                                                    child:
                                                        RaisedRoundedGradientButton(
                                                      child: Text('Submit',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor)),
                                                      onPressed: () async {
                                                        await SmsAutoFill()
                                                            .listenForCode;
                                                        if (_phoneFormKey
                                                            .currentState
                                                            .validate()) {
                                                          setState(() {
                                                            gotPhoneNumber =
                                                                true;
                                                          });
                                                          try {
                                                            log.i(
                                                                'CognitoService.forgotPassword');
                                                            Map<String, Object>
                                                                forgotPasswordResponse =
                                                                await CognitoService
                                                                    .instance
                                                                    .forgotPassword(
                                                                        "+1$phoneNumber");
                                                            log.d(
                                                                'forgotPasswordResponse: ${forgotPasswordResponse['status']}');
                                                            if (forgotPasswordResponse[
                                                                    'status'] ==
                                                                true) {
                                                              log.d(
                                                                  'cognitoUser: ${forgotPasswordResponse['cognitoUser']}');
                                                              setState(() {
                                                                cognitoUser =
                                                                    forgotPasswordResponse[
                                                                        'cognitoUser'];
                                                              });
                                                            }
                                                          } on CognitoClientException catch (e) {
                                                            log.e(e);
                                                            if (e.code ==
                                                                'LimitExceededException') {
                                                              CustomToast.showDialog(
                                                                  'Too many password reset attempts. Please wait a bit and try again.',
                                                                  context,
                                                                  Toast.BOTTOM);
                                                              log.i(
                                                                  'Waiting 2 seconds for Toast to disappear and pushing to Authenticate');
                                                              await Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                                  () {
                                                                Navigator
                                                                    .pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              Authenticate()),
                                                                );
                                                              });
                                                            } else {
                                                              rethrow;
                                                            }
                                                          } catch (e) {
                                                            log.e(e);
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  fallbackBuilder: (BuildContext context) {
                                    return Container(
                                        child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Text(
                                          'OTP Code',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        Form(
                                          key: formKey,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 30),
                                              child: PinCodeTextField(
                                                onChanged: (v) {
                                                  print('somwthing');
                                                },
                                                appContext: context,
                                                pastedTextStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryVariant,
                                                ),
                                                length: 6,
                                                textStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .hintColor),
                                                blinkWhenObscuring: true,
                                                animationType:
                                                    AnimationType.fade,
                                                pinTheme: PinTheme(
                                                  shape: PinCodeFieldShape
                                                      .underline,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  fieldHeight: 50,
                                                  fieldWidth: 40,
                                                  activeFillColor:
                                                      Colors.transparent,
                                                  selectedColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                  inactiveColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryVariant,
                                                  activeColor: Theme.of(context)
                                                      .hintColor,

                                                  inactiveFillColor:
                                                      Colors.transparent,
                                                  selectedFillColor:
                                                      Colors.transparent,
                                                  // activeColor: Colors.black,
                                                ),
                                                cursorColor: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                animationDuration:
                                                    Duration(milliseconds: 300),
                                                enableActiveFill: true,
                                                errorAnimationController:
                                                    errorController,
                                                controller:
                                                    textEditingController,
                                                keyboardType:
                                                    TextInputType.number,
                                                onCompleted: (v) {
                                                  _otp = v;
                                                },
                                              )),
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (.6 + (.1 / 3) * 5),
                                          child: TextFormField(
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
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (.6 + (.1 / 3) * 5),
                                          child: TextFormField(
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
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        RaisedRoundedGradientButton(
                                          onPressed: () async {
                                            if (_formKey.currentState
                                                .validate()) {
                                              if (didPressSubmit == false) {
                                                log.i('didPressSubmit');
                                                setState(() {
                                                  didPressSubmit = true;
                                                });
                                                //log.d(_otp);
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                try {
                                                  log.i(
                                                      'CognitoService.confirmPassword');
                                                  Map<String, Object>
                                                      confirmPasswordResponse =
                                                      await CognitoService
                                                          .instance
                                                          .confirmPassword(
                                                              cognitoUser,
                                                              _otp,
                                                              password2);
                                                  log.d(
                                                      'confirmPasswordResponse: ${confirmPasswordResponse['status']}');
                                                  if (confirmPasswordResponse[
                                                          'status'] ==
                                                      true) {
                                                    CustomToast.showDialog(
                                                        'Successfully reset password!',
                                                        context,
                                                        Toast.BOTTOM);
                                                    log.i(
                                                        'Waiting 2 seconds for Toast to disappear and pushing to Authenticate');
                                                    await Future.delayed(
                                                        Duration(seconds: 2),
                                                        () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Authenticate()),
                                                      );
                                                    });
                                                  }
                                                } on CognitoClientException catch (e) {
                                                  log.e(e);
                                                  if (e.code ==
                                                      'CodeMismatchException') {
                                                    log.e('Incorrect OTP code');
                                                    CustomToast.showDialog(
                                                        'Incorrect OTP code. Please try again!',
                                                        context,
                                                        Toast.BOTTOM);
                                                    setState(() {
                                                      didPressSubmit = false;
                                                    });
                                                  } else {
                                                    rethrow;
                                                  }
                                                } catch (e) {
                                                  log.e(
                                                      'Reset password failed');
                                                  log.e(e);
                                                  CustomToast.showDialog(
                                                      'Password reset failed. Returning you to sign in',
                                                      context,
                                                      Toast.BOTTOM);
                                                  log.i(
                                                      'Waiting 2 seconds for Toast to disappear and pushing to Authenticate');
                                                  await Future.delayed(
                                                      Duration(seconds: 2), () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Authenticate()),
                                                    );
                                                  });
                                                }
                                              }
                                            } else {
                                              log.i(
                                                  'Waiting 2 seconds and allowing submit button press again');
                                              await Future.delayed(
                                                  Duration(seconds: 2), () {
                                                setState(() {
                                                  didPressSubmit = false;
                                                });
                                              });
                                            }
                                          },
                                          child: didPressSubmit == true
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
                                                  'Update Password',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                        )
                                      ],
                                    ));
                                  })
                            ]))
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
