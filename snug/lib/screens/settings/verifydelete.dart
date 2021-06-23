import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snug/core/errors/DeleteUserDatesException.dart';
import 'package:snug/core/errors/DeleteUserException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/models/Contact.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/services/remote_db_service.dart';
import 'package:toast/toast.dart';

class VerifyDelete extends StatefulWidget {
  @override
  _VerifyDeleteState createState() => _VerifyDeleteState();
}

class _VerifyDeleteState extends State<VerifyDelete> {
  final log = getLogger('verifyDelete');
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
              final dateProvider =
                  Provider.of<DateProvider>(context, listen: false);
              final contactProvider =
                  Provider.of<ContactProvider>(context, listen: false);
              SharedPreferences prefs = await SharedPreferences.getInstance();

              CognitoUser cognitoUser = userProvider.getCognitoUser;
              try {
                String _userId = userProvider.getUser.uid;
                log.d('deleting dates');
                Map<String, Object> deleteDatesResult =
                    await RemoteDatabaseHelper.instance
                        .deleteUserDates(_userId);
                if (deleteDatesResult['status'] == true) {
                  log.d('deleting user');
                  Map<String, Object> deleteUserResult =
                      await RemoteDatabaseHelper.instance.deleteUser(_userId);
                  if (deleteUserResult['status'] == true) {
                    log.d('deleting cognito user');
                    Map<String, Object> deleteCognitoResult =
                        await CognitoService.instance.deleteUser(cognitoUser);
                    if (deleteCognitoResult['status'] == true) {
                      log.d('deleting providers');
                      //clear all data from app
                      userProvider.removeUser();
                      contactProvider.removeAllContacts();
                      dateProvider.removeAllDates();
                      prefs.clear();

                      CustomToast.showDialog(
                          'Thanks for using Snug! See ya later.',
                          context,
                          Toast.BOTTOM);
                      await Future.delayed(Duration(seconds: 2), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Authenticate()),
                        );
                      });
                    }
                  }
                }
              } catch (e) {
                log.e(e);
                CustomToast.showDialog(
                    'Failed to delete account, please try again.',
                    context,
                    Toast.BOTTOM);
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
