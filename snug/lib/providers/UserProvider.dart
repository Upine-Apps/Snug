import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:snug/models/User.dart';

class UserProvider extends ChangeNotifier {
  User _user = new User();
  CognitoUserSession _userSession;
  CognitoUser _cognitoUser;

  User get getUser {
    return _user;
  }

  CognitoUserSession get getUserSession {
    return _userSession;
  }

  CognitoUser get getCognitoUser {
    return _cognitoUser;
  }

  setCognitoUser(CognitoUser curCognitoUser) {
    _cognitoUser = curCognitoUser;
  }

  setUserSession(CognitoUserSession curSession) {
    _userSession = curSession;
  }

  editUser(User tempUser) {
    //this might be a bit overkill but it should work
    var userMap = tempUser.toMapWithId(); //edited user data into map
    var curUser = _user.toMapWithId(); //original user data into map
    for (var prop in userMap.keys) {
      if (userMap[prop] != null) {
        curUser['$prop'] = userMap[prop];
        print(userMap[prop]); //set current user map prop to updated
      }
      //iterate through keys in map

    }
    _user = User.fromMap(curUser);
    notifyListeners();
  }

  removeUser() {
    _user = User();
    notifyListeners();
  }
}
