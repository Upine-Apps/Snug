import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/services/remote_db_service.dart';

class VerifyDelete extends StatefulWidget {
  @override
  _VerifyDeleteState createState() => _VerifyDeleteState();
}

class _VerifyDeleteState extends State<VerifyDelete> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Are you sure you want to delete your account?',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              CognitoUser cognitoUser = userProvider.getCognitoUser;
              try {
                String _userId = userProvider.getUser.uid;

                Map<String, Object> deleteDatesResult =
                    await RemoteDatabaseHelper.instance
                        .deleteUserDates(_userId);
                if (deleteDatesResult['status' == true]) {
                  Map<String, Object> deleteUserResult =
                      await RemoteDatabaseHelper.instance.deleteUser(_userId);
                  if (deleteUserResult['status'] == true) {
                    Map<String, Object> deleteCognitoResult =
                        await CognitoService.instance.deleteUser(cognitoUser);
                    if (deleteCognitoResult['status'] == true) {
                      CustomToast.showDialog(
                          'Thanks for using Snug! See ya later.', context);
                      await Future.delayed(Duration(seconds: 2), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Authenticate()),
                        );
                      });
                    } else {
                      throw Error;
                    }
                  } else {
                    throw Error;
                  }
                } else {
                  throw Error;
                }
              } catch (e) {
                CustomToast.showDialog(
                    'Failed to delete account, please try again.', context);
                await Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context).pop(false);
                });
              }
            },
            child: Text('Yes',
                style: TextStyle(color: Theme.of(context).dividerColor)),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('No',
                style: TextStyle(color: Theme.of(context).dividerColor)),
          )
        ]);
  }
}
