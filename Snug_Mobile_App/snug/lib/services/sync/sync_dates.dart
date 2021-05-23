import 'package:flutter/cupertino.dart';
import 'package:snug/core/errors/DateNotSyncedError.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/services/remote_db_service.dart';
import 'package:provider/provider.dart';

Future syncDates(String _userId, BuildContext context) async {
  final log = getLogger('syncDates');
  log.i('syncDates | userId: $_userId BuildContext: $context');
  final dateProvider = Provider.of<DateProvider>(context, listen: false);
  try {
    var result = await RemoteDatabaseHelper.instance.getUserDates(_userId);
    if (result['status'] == true) {
      for (var _date in result['data']) {
        log.d(_date);
        var userTwoResponse = await RemoteDatabaseHelper.instance.getUser(
            _date['user_2'].toString(),
            _date['user_2']
                .toString()); //delete the second one when you add in firebase
        if (userTwoResponse['status'] == true) {
          _date['who'] = User.fromMap(userTwoResponse['data']);
          Date _tempDate = Date.fromMap(_date);
          await dateProvider.addDate(_tempDate);
          // if (addDateSuccess) {
          //   continue;
          // } else {
          //   throw DateNotSyncedException(
          //       'One or more dates failed to add to the provider');
          // }
        } else {
          throw DateNotSyncedException('Failed to fetch user 2 name');
        }
      }
      return {'status': true};
    } else {
      throw DateNotSyncedException('Failed to sync dates');
    }
  } catch (e) {
    log.e('Caught exception $e');
    return {'status': false};
  }
}
