import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:snug/core/errors/OTPException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/authenticate/profile.dart';
import 'package:snug/screens/sync/sync.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/themes/apptheme.dart';
import 'package:snug/themes/themeNotifier.dart';
import 'package:snug/custom_widgets/OtpScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

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
  bool returnToSignIn = false;

  Future<String> validateOtp(String confirmationCode) async {
    print('Pressed button to validate');
    final _userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      Map<String, Object> confirmationResult = await CognitoService.instance
          .confirmUser('+1${widget.phonenumber}', confirmationCode);
      if (confirmationResult['status'] == true) {
        Map<String, Object> signInResult = await CognitoService.instance
            .signInUser('+1${widget.phonenumber}', widget.password);
        if (signInResult['status'] == true) {
          CognitoUser confirmedUser = signInResult['cognitoUser'];
          CognitoUserSession userSession = signInResult['cognitoSession'];
          _userProvider.setCognitoUser(confirmedUser);
          _userProvider.setUserSession(userSession);
          setState(() {
            cognitoUser = signInResult['cognitoUser'];
          });
          log.i('pushToProfileCreation');
          return null;
        } else {
          log.e('ERROR: ${signInResult['message']} | ${signInResult['error']}');
          log.i('pushToAuthenticate');
          throw Error;
        }
      }
    } on OTPException catch (e) {
      log.e(e);
      return ('Incorrect OTP code');
    } catch (e) {
      await Future.delayed(Duration(seconds: 2), () {
        CustomToast.showDialog(
            'Error signing in. Returning you to the sign in screen',
            context,
            Toast.BOTTOM);
      });
      setState(() {
        returnToSignIn = true;
      });
      return null;
    }
  }

  void moveToNextScreen(context) {
    if (returnToSignIn == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Authenticate()),
      );
    } else {
      Navigator.pushReplacement(
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
                        onPressed: () async {
                          try {
                            await CognitoService.instance.resendCode(
                                widget.phonenumber, widget.password);
                          } catch (e) {
                            CustomToast.showDialog(
                                'Failed to resend OTP code. Please check your texts for the original code',
                                context,
                                Toast.BOTTOM);
                          }
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
