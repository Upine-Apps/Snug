import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/authenticate/profile.dart';
import 'package:snug/screens/sync/sync.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/themes/apptheme.dart';
import 'package:snug/themes/themeNotifier.dart';
import 'package:otp_screen/otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otp extends StatefulWidget {
  final String phonenumber;
  final Function toggleView;
  final String password;
  final bool fromSignIn;
  Otp(
      {this.toggleView,
      @required this.phonenumber,
      @required this.password,
      @required this.fromSignIn});
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final log = getLogger('Otp');
  CognitoUser cognitoUser;
  pushToAuthentication(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Authenticate()),
    );
  }

  Future<String> validateOtp(String confirmationCode) async {
    print('Pressed button to validate');
    Map<String, Object> confirmationResult = await CognitoService.instance
        .confirmUser('+1${widget.phonenumber}', confirmationCode);
    if (confirmationResult['status'] == true) {
      Map<String, Object> signInResult = await CognitoService.instance
          .signInUser('+1${widget.phonenumber}', widget.password);
      if (signInResult['status'] == true) {
        if (widget.fromSignIn) {
          CognitoUser confirmedUser = signInResult['cognitoUser'];
          Map<String, Object> getAttributesResult =
              await CognitoService.instance.getUserAttributes(confirmedUser);
          if (getAttributesResult['status'] == true) {
            String user_id = getAttributesResult['data'];
            SharedPreferences _profile = await SharedPreferences.getInstance();
            log.i('User id: $user_id');
            _profile.setString('uid', user_id);
            _profile.setString('phonenumber', widget.phonenumber);
            log.i('pushToMainPage');

            return null;
          } else if (getAttributesResult['status'] == false) {
            //toast to let them know there was an error getting their user_id, returning to sign in screen
            //wait one second
            log.e(
                'ERROR: ${getAttributesResult['message']} | ${getAttributesResult['error']}');
            log.i('pushToAuthenticate');

            return 'The OTP was incorrect';
          } else {
            //toast them to let them know there was an error signing in and to try again
            //wait one second
            //return to authentication screen
            log.i('pushToAuthenticate');
            return 'Attribute error';
          }
        } else {
          setState(() {
            cognitoUser = signInResult['cognitoUser'];
          });
          //toast to let them know they successfully confirmed their account
          //wait one second
          //push to profile creation screen
          log.i('pushToProfileCreation');
          return null;
        }
      } else if (signInResult['status'] == false) {
        //THIS MIGHT BE OVERKILL BUT I JUST WANT TO MAKE SURE ALL THE CASES ARE COVERED
        //toast them to let them know there was an error signing in and to try again
        //wait one second
        //return to authentication screen
        log.e('ERROR: ${signInResult['message']} | ${signInResult['error']}');
        log.i('pushToAuthenticate');
        return 'Sign In error';
      } else {
        //toast them to let them know there was an error signing in and to try again
        //wait one second
        //return to authentication screen
        log.i('pushToAuthenticate');
        return 'Sign In error';
      }
    } else if (confirmationResult['status'] == false) {
      log.e('${confirmationResult['message']}: ${confirmationResult['error']}');
      //toast to notify of the error
      if (confirmationResult['message'] == 'INCORRECT_OTP') {
        log.i('Incorrect OTP code');
        return "Incorrect OTP code";
        //add resend functionality here
      } else {
        log.e(
            'ERROR: ${confirmationResult['message']} | ${confirmationResult['error']}');
        log.i('pushToAuthenticate');
        //toast them to let them know there was an error
        //wait one second
        //return to authentication screen
        return 'OTP error';
      }
    } else {
      //toast them to let them know there was an error
      //wait one second
      //return to authentication screen
      log.i('pushToAuthenticate');
      return "OTP error";
    }
  }

  //do we need this?
  void moveToNextScreen(context) {
    if (widget.fromSignIn == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SyncScreen()),
      );
    } else if (widget.fromSignIn == false) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                phonenumber: widget.phonenumber, cognitoUser: cognitoUser)),
      );
    }
  }

  @override
  //ADD BACK BUTTON TO SEND BACK TO SIGN IN SCREEN
  //ADD RESEND VERFICATION BUTTON
  Widget build(BuildContext context) {
    String text = '';
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
          theme: AppTheme().lightTheme,
          darkTheme: AppTheme().darkTheme,
          themeMode: themeNotifier.getThemeMode(),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.arrow_back,
                          color:
                              Theme.of(context).colorScheme.secondaryVariant),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Authenticate()),
                        );
                      },
                    ),
                    FlatButton(
                        onPressed: () {
                          //INSERT CODE TO RESEND VERFICATION CODE
                        },
                        child: Text('Resend Code'))
                  ],
                )),
            body: OtpScreen.withGradientBackground(
                topColor: Theme.of(context).colorScheme.primary,
                bottomColor: Theme.of(context).colorScheme.secondary,
                otpLength: 6,
                validateOtp: validateOtp,
                routeCallback: moveToNextScreen,
                themeColor: Colors.white,
                titleColor: Colors.white,
                title: "Verify your Phone Number",
                subTitle: "Enter the code sent to ${widget.phonenumber}",
                icon: Image.asset('assets/image/smartphone.png',
                    fit: BoxFit.fill)),
          )),
    );
  }
}
