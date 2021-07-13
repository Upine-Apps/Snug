import 'package:flutter/cupertino.dart';
import 'package:snug/core/errors/GetUserException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/services/remote_db_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future syncUser(String userId, BuildContext context) async {
  //final log = getLogger('syncUser');
  //log.i('syncUser | userId: $userId BuildContext: $context');
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  SharedPreferences _profile = await SharedPreferences.getInstance();

  try {
    var result = await RemoteDatabaseHelper.instance.getUser(userId);
    if (result['status'] == true) {
      User _user = User.fromMap(result['data']);
      userProvider.editUser(_user);
      _profile.setString('first_name', _user.first_name);
      return {
        'status': true,
        'data': _user,
        'trusted_contacts': result['data']['trusted_contacts']
      };
    } else {
      throw GetUserException('Failed to sync user.');
    }
  } catch (e) {
    //log.e('Error syncing user. Caught exception: %e');
    return {'status': false, 'data': null, 'trusted_contacts': null};
  }
}
