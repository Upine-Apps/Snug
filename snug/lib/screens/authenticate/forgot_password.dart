import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/authenticate/sign_in.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:toast/toast.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  void initState() {
    super.initState;
    listenForCode();
  }

  listenForCode() async {
    await SmsAutoFill().listenForCode;
  }

  String _otpCode = '';
  String phoneNumber;
  bool didPressSubmit = false;
  bool gotPhoneNumber = false;
  CognitoUser cognitoUser;
  var _formKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final log = getLogger('forgotPassword');
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignIn())),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          body: Center(
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
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
                      Form(
                          key: _formKey,
                          child: Column(children: <Widget>[
                            Conditional.single(
                                context: context,
                                conditionBuilder: (BuildContext context) =>
                                    gotPhoneNumber == false,
                                widgetBuilder: (BuildContext context) {
                                  return Column(children: <Widget>[
                                    Container(
                                        child: Form(
                                      key: _phoneFormKey,
                                      child: Column(children: <Widget>[
                                        Container(
                                            child: TextFormField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp('[0-9]+')),
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
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor)),
                                              labelText: 'Phone Number'),
                                          onChanged: (val) {
                                            setState(() {
                                              phoneNumber = val;
                                            });
                                          },
                                        )),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .05),
                                            child: Container(
                                                child:
                                                    RaisedRoundedGradientButton(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .5,
                                                        child: Text('Submit',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor)),
                                                        onPressed: () async {
                                                          if (_phoneFormKey
                                                              .currentState
                                                              .validate()) {
                                                            setState(() {
                                                              gotPhoneNumber =
                                                                  true;
                                                            });
                                                            try {
                                                              Map<String,
                                                                      Object>
                                                                  forgotPasswordResponse =
                                                                  await CognitoService
                                                                      .instance
                                                                      .forgotPassword(
                                                                          "+1$phoneNumber");
                                                              if (forgotPasswordResponse[
                                                                      'status'] ==
                                                                  true) {
                                                                setState(() {
                                                                  cognitoUser =
                                                                      forgotPasswordResponse[
                                                                          'cognitoUser'];
                                                                });
                                                              }
                                                            } catch (e) {
                                                              log.e(e);
                                                            }
                                                          }
                                                        }))),
                                      ]),
                                    ))
                                  ]);
                                },
                                fallbackBuilder: (BuildContext context) {
                                  return PinFieldAutoFill(
                                    decoration: UnderlineDecoration(
                                      textStyle: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                      colorBuilder: FixedColorBuilder(
                                          Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                    ),
                                    currentCode: _otpCode,
                                    onCodeChanged: (code) async {
                                      if (code.length == 6 &&
                                          didPressSubmit == false) {
                                        setState(() {
                                          didPressSubmit = true;
                                        });
                                        log.d(code);
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        try {
                                          Map<String, Object>
                                              confirmPasswordResponse =
                                              await CognitoService.instance
                                                  .confirmPassword(cognitoUser,
                                                      code, 'apples');
                                          if (confirmPasswordResponse[
                                                  'status'] ==
                                              true) {
                                            CustomToast.showDialog(
                                                'Successfully reset password!',
                                                context,
                                                Toast.BOTTOM);
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
                                        } on CognitoClientException catch (e) {
                                          if (e.code ==
                                              'CodeMismatchException') {
                                            CustomToast.showDialog(
                                                'Incorrect OTP code. Please try again!',
                                                context,
                                                Toast.BOTTOM);
                                            setState(() {
                                              didPressSubmit = false;
                                            });
                                          }
                                          log.e(e);
                                        }
                                        // try{
                                        //   cognitoService.
                                        // }
                                      }
                                    },
                                  );
                                })
                          ]))
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
