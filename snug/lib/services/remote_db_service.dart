import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snug/core/errors/AddContactException.dart';
import 'package:snug/core/errors/AddDateException.dart';
import 'package:snug/core/errors/AddUserException.dart';
import 'package:snug/core/errors/ContactException.dart';
import 'package:snug/core/errors/DateNotFoundException.dart';
import 'package:snug/core/errors/DatesNotFoundException.dart';
import 'package:snug/core/errors/GetUserException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/models/Contact.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/models/User.dart';
import 'package:http/http.dart' as http;

class RemoteDatabaseHelper {
  Future<Object> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    final _headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      'accesstoken': accessToken
    };
    return _headers;
  }

  static final _hostUrl = DotEnv().env['BACKEND_IP'];
  final log = getLogger('RemoteDatabaseHelper');

  RemoteDatabaseHelper._privateConstructor();
  static final RemoteDatabaseHelper instance =
      new RemoteDatabaseHelper._privateConstructor();
/*
  Get user data from remote and return for updating local yuser profile shared preferences
*/
  Future getUser(String userId, [testing]) async {
    //testing purposes
    // userId = '1';
    if (testing != null) {
      userId = testing;
    }
    final urlProfile = '$_hostUrl/users/$userId';
    log.i('getUser | userId: $userId');
    try {
      var _headers = await getHeaders();
      var responseUser = await http.get(urlProfile, headers: _headers);
      var extractData = json.decode(responseUser.body);
      if (extractData['status'] == true) {
        extractData = extractData['data'];
        if (extractData['height'] != null) {
          extractData['ft'] = extractData['height'] ~/ 12;
          extractData['inch'] = extractData['height'] % 12;
        }
        if (extractData['dob'] != null) {
          extractData['dob'] = extractData['dob'].toString().substring(0, 10);
        }
        log.i('getUser succeeded!');
        return {'status': true, 'data': extractData};
      } else {
        throw new GetUserException('Error getting the user profile');
      }
    } catch (e) {
      log.e('Failed to get user. Caught exception $e');
      return {'status': false, 'data': null};
    }
    //update user shared preferences here
  }

  Future getRegisteredUserByPhone(String phone_number) async {
    final urlProfile = '$_hostUrl/users/registered/phonenumber/$phone_number';
    log.i('getRegisteredUserByPhone | phone_number: $phone_number');
    var _headers = await getHeaders();
    try {
      var responseUser = await http.get(urlProfile, headers: _headers);
      var extractData = json.decode(responseUser.body);
      if (extractData['status'] == true) {
        extractData = extractData['data'];
        extractData['ft'] = extractData['height'] ~/ 12;
        extractData['inch'] = extractData['height'] % 12;
        extractData['dob'] = extractData['dob'].toString().substring(0, 10);
        log.d(extractData['in']);
        log.i('getRegisteredUserByPhone succeeded!');
        return {'status': true, 'data': extractData};
      } else {
        throw new GetUserException('Error getting the user profile');
      }
    } catch (e) {
      log.e('Failed to get user. Caught exception $e');
      return {'status': false, 'data': null};
    }
    //update user shared preferences here
  }

  Future addUser(User _user) async {
    log.i('addUser | _user: $_user');
    final urlAddUser = '$_hostUrl/users';
    var _headers = await getHeaders();
    Map<String, dynamic> _tempUser = _user.toMapWithoutId();
    if (_user.ft != null && _user.inch != null) {
      _tempUser['height'] =
          ((int.parse(_user.ft) * 12) + int.parse(_user.inch)).toString();
    }
    _tempUser.remove('ft');
    _tempUser.remove('inch');
    log.d('keys: ${_tempUser.keys}');
    _tempUser.removeWhere((key, value) => key == null || value == null);
    try {
      print('before http');
      var responseAddUser = await http.post(Uri.encodeFull(urlAddUser),
          headers: _headers, body: _tempUser);
      print('after http');
      var extractData = json.decode(responseAddUser.body);
      if (extractData['status'] == true) {
        log.i('addUser succeeded!');

        return {'status': true, 'user_id': extractData['data']};
      } else {
        throw AddUserException('Error adding user.');
      }
    } catch (e) {
      log.e('Failed to add user. Caught exception $e');
      return {'status': false};
    }
  }

  Future updateUser(User _user, String userId) async {
    log.i('updateUser | _user: $_user');
    final urlAddUser = '$_hostUrl/users/$userId';
    var _headers = await getHeaders();
    Map<String, dynamic> _tempUser = _user.toMapWithId();
    _tempUser['height'] =
        ((int.parse(_user.ft) * 12) + int.parse(_user.inch)).toString();
    _tempUser.remove('ft');
    _tempUser.remove('inch');
    try {
      var responseAddUser = await http.put(Uri.encodeFull(urlAddUser),
          headers: _headers, body: _tempUser);
      var extractData = json.decode(responseAddUser.body);
      if (extractData['status'] == true) {
        log.i('addUser succeeded!');

        return {'status': true, 'user_id': extractData['data']};
      } else {
        throw AddUserException('Error adding user.');
      }
    } catch (e) {
      log.e('Failed to update user. Caught exception $e');
      return {'status': false};
    }
  }

/*
Pull user's trusted contacts from remote and update their local trusted contacts
This is only to be used when they first download the application
*/
  Future getContacts(List<String> trustedContacts) async {
    List<String> phoneNumbersToReturn = [];
    final urlContacts = '$_hostUrl/api/get-contact-by-id';
    log.i('getContacts | trustedContacts: $trustedContacts');
    var _headers = await getHeaders();
    try {
      for (var contact_id in trustedContacts) {
        var responseContact = await http.post(Uri.encodeFull(urlContacts),
            headers: _headers, body: {"contact_id": contact_id});
        var extractData = json.decode(responseContact.body);
        if (extractData['status'] == true) {
          phoneNumbersToReturn
              .add(extractData['data']['phone_number'].toString());
        } else {
          throw ContactException('Error getting contact info.');
        }
      }
      log.i('getContacts succeeded!');
      return {'status': true, 'data': phoneNumbersToReturn};
    } catch (e) {
      log.e('Failed to get contact. Caught exception $e');
      return {'status': false, 'data': null};
    }
  }

  Future addTrustedContacts(
      List<Contact> trustedContacts, String userId) async {
    log.i(
        'addTrustedContacts | trustedContacts: $trustedContacts userId: $userId');
    final urlAddContacts = '$_hostUrl/users/$userId/trusted';
    var _headers = await getHeaders();
    Map<String, dynamic> dataToSend = {};
    try {
      for (int i = 0; i < trustedContacts.length; i++) {
        dataToSend['trusted_${i + 1}'] = trustedContacts[i].toMap();
      }
      var responseAddTrusted = await http.put(Uri.encodeFull(urlAddContacts),
          headers: _headers,
          body: {'trusted_contacts': json.encode(dataToSend)});
      var extractData = json.decode(responseAddTrusted.body);
      if (extractData['status'] == true) {
        log.i('addTrustedContacts succeeded!');
        return {'status': true};
      } else {
        throw AddContactException('Error adding trusted contact.');
      }
    } catch (e) {
      log.e('Failed to add contacts. Caught exception $e');
      return {'status': false};
    }
  }

  Future getUserDates(String userId) async {
    //for testing purposes
    // userId = '1';
    final urlDates = '$_hostUrl/users/$userId/dates';
    var _headers = await getHeaders();
    try {
      var datesResponse = await http.get(urlDates, headers: _headers);
      var extractData = json.decode(datesResponse.body);
      if (extractData['status'] == true) {
        return {'status': true, 'data': extractData['data']};
      } else {
        throw DatesNotFoundException('Error getting dates.');
      }
    } catch (e) {
      log.e('Failed to get dates. Caught exception $e');
      return {'status': false, 'data': null};
    }
  }

  Future getUserTwo(String userId) async {
    final urlGetReportedUser = '$_hostUrl/users/$userId';
    var _headers = await getHeaders();
    try {
      var reportedResponse =
          await http.get(urlGetReportedUser, headers: _headers);
      var extractData = json.decode(reportedResponse.body);
      var fullUser = extractData['data'];
      return {'status': true, 'data': fullUser};
    } catch (e) {
      log.e('Failed to get second user. Caught exception $e');
      return {'status': false, 'data': null};
    }
  }

  Future addDate(Date currentDate, String userId) async {
    log.i('addDate | currentDate: $currentDate userId: $userId');
    var _headers = await getHeaders();
    final urlAddDate = '$_hostUrl/dates';
    Map<String, dynamic> dateToSend = currentDate.toMapWithoutId();
    dateToSend['user_1'] = userId;
    dateToSend['date_location'] =
        "(${currentDate.dateLocation['lat']}, ${currentDate.dateLocation['long']})";
    dateToSend.remove('who');
    try {
      var responseAddDate = await http.post(Uri.encodeFull(urlAddDate),
          headers: _headers, body: {'new_date': json.encode(dateToSend)});
      var extractData = json.decode(responseAddDate.body);
      if (extractData['status'] == true) {
        log.i('addDate succeeded!');
        return {'status': true};
      } else {
        throw AddDateException('Error adding date.');
      }
    } catch (e) {
      log.e('Failed to add date. Caught exception $e');
      return {'status': false};
    }
  }

  Future deleteDate(String dateId) async {
    log.i('deleteDate | dateId: $dateId');
    final urlCancelDate = '$_hostUrl/dates/cancel/$dateId';
    var _headers = await getHeaders();
    try {
      var responseCancelDate =
          await http.put(Uri.encodeFull(urlCancelDate), headers: _headers);
      var extractData = json.decode(responseCancelDate.body);
      if (extractData['status'] == true) {
        log.i('cancelDate succeeded!');
        return {'status': true};
      } else {
        throw DateNotFoundException("Couldn't find date.");
      }
    } catch (e) {
      log.e('Failed to cancel date. Caught exception $e');
      return {'status': false};
    }
  }

  Future markDateSafe(String dateId) async {
    log.i('markDateSafe | dateId: $dateId');
    final urlMarkSafe = '$_hostUrl/dates/safe/$dateId';
    var _headers = await getHeaders();
    try {
      var responseMarkSafe =
          await http.put(Uri.encodeFull(urlMarkSafe), headers: _headers);
      var extractData = json.decode(responseMarkSafe.body);
      if (extractData['status'] == true) {
        log.i('markDateSafe succeeded!');
        return {'status': true};
      } else {
        throw DateNotFoundException("Couldn't find date.");
      }
    } catch (e) {
      log.e('Failed to mark date safe. Caught exception $e');
      return {'status': false};
    }
  }
}
