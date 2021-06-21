import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';

import 'package:shared_preferences/shared_preferences.dart';
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

  final userPool =
      CognitoUserPool('us-east-2_rweyLTmso', '26gd072a3jrqsjubrmaj0r4nr3');
  @override
  void initState() {
    super.initState();
    // autoLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getInfo();
    });
    myFocusNode.addListener(() {
      print("Has focus: ${myFocusNode.hasFocus}");
    });
  }

  final TextEditingController _controller = TextEditingController();
  Future<void> getInfo() async {
    log.i('getInfo | null');
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    log.i('displayName | $fname');
    if (fname != null) {
      return Text('Welcome Back, $fname!');
    } else {
      return Text('Welcome!');
    }
  }

  final log = getLogger('SignIn');

  @override
  Widget build(BuildContext context) {
    final _userProvider = Provider.of<UserProvider>(context, listen: true);
    final node = FocusScope.of(context);
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
                                      icon: Icon(Icons.phone),
                                      labelText: 'Phone Number',
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                    validator: (String val) {
                                      if (val.length != 10) {
                                        return "Please enter a valid Phone Number";
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
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.security),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                    obscureText: true,
                                    onChanged: (val) {
                                      log.i('setPassword | ****');
                                      setState(() => password = val);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  RaisedRoundedGradientButton(
                                      width: MediaQuery.of(context).size.width *
                                          .5,
                                      child: Text(
                                        'Login',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        print(didPressLogin);
                                        if (didPressLogin == false) {
                                          log.i('PRESSED');
                                          //fix double tap issue
                                          setState(() {
                                            didPressLogin = true;
                                          });
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());

                                          if (_formKey.currentState
                                              .validate()) {
                                            try {
                                              log.i(phonenumber);
                                              log.i(password);
                                              Map<String, Object> result =
                                                  await CognitoService.instance
                                                      .signInUser(
                                                          '+1$phonenumber',
                                                          password);
                                              if (result['status'] == true) {
                                                //dont need OTP
                                                CognitoUser confirmedUser =
                                                    result['cognitoUser'];
                                                CognitoUserSession userSession =
                                                    result['cognitoSession'];
                                                _userProvider.setCognitoUser(
                                                    confirmedUser);
                                                _userProvider.setUserSession(
                                                    userSession);
                                                try {
                                                  Map<String, Object>
                                                      getAttributesResult =
                                                      await CognitoService
                                                          .instance
                                                          .getUserAttributes(
                                                              confirmedUser);
                                                  if (getAttributesResult[
                                                          'status'] ==
                                                      true) {
                                                    String user_id =
                                                        getAttributesResult[
                                                            'data'];
                                                    SharedPreferences _profile =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    log.i('User id: $user_id');
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
                                                    'shouldnt have gotten here...');
                                                throw Error;
                                              }
                                            } on CognitoClientException catch (e) {
                                              log.w(e);
                                              if (e.code ==
                                                  'UserNotConfirmedException') {
                                                log.e('OTP needed');
                                                CognitoService.instance
                                                    .resendCode(
                                                        phonenumber, password);
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
                                                    'Incorrect password',
                                                    context,
                                                    Toast.BOTTOM);
                                                await Future.delayed(
                                                    Duration(seconds: 2), () {
                                                  setState(() {
                                                    didPressLogin = false;
                                                  });
                                                });
                                              }
                                            } on CognitoUserMfaRequiredException catch (e) {
                                              log.e('MFA Needed');
                                              CognitoService.instance
                                                  .resendCode(
                                                      phonenumber, password);
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
                                            }
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
                                            Navigator.pushReplacement(
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
