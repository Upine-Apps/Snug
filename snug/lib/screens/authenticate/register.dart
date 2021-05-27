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
  final log = getLogger('Register');
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    return Scaffold(
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
                          Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  TextFormField(
                                    onEditingComplete: () => node.nextFocus(),
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
                                        icon: Icon(Icons.phone),
                                        labelText: 'Phone Number'),
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
                                    controller: _passOne,
                                    onEditingComplete: () => node.nextFocus(),
                                    decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryVariant),
                                        icon: Icon(Icons.security),
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
                                        icon: Icon(Icons.security),
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
                                  RaisedRoundedGradientButton(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    child: Text(
                                      'Register',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        try {
                                          Map<String, Object> result =
                                              await CognitoService.instance
                                                  .registerUser(
                                                      phonenumber, password2);
                                          if (result['status'] == false) {
                                            if (result['message'] == 'ERROR') {
                                              CustomToast.showDialog(
                                                  'Something went wrong, please try again. $somethingWentWrong',
                                                  context);
                                            } else if (result['message'] ==
                                                'REGISTRATION_FAILED') {
                                              CustomToast.showDialog(
                                                  'Registration failed, please try again later. $somethingWentWrong',
                                                  context);
                                              //toast to say registration failed and give reason
                                              //LOOK INTO THE POSSIBLE REASONS AND RETURN FROM THE COGNITO SERVICE CLASS
                                            }
                                          } else if (result['status'] == true) {
                                            SharedPreferences _profile =
                                                await SharedPreferences
                                                    .getInstance();
                                            _profile.setString(
                                                'phonenumber', phonenumber);

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Otp(
                                                        phonenumber:
                                                            phonenumber,
                                                        password: password2,
                                                        fromSignIn: false,
                                                      )),
                                            );
                                          }
                                        } catch (e) {
                                          log.d('registration error');
                                          log.e(e);
                                        }
                                      }
                                    },
                                  )
                                ],
                              ))
                        ])))));
  }
}
