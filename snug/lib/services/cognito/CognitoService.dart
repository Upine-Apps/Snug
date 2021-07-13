import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snug/core/errors/AddUserAttributeException.dart';
import 'package:snug/core/errors/GetUserAttributeException.dart';
import 'package:snug/core/errors/OTPException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/providers/UserProvider.dart';

class CognitoService {
  static String userPoolId =
      'us-east-2_rweyLTmso'; //DotEnv().env['COGNITO_USER_POOL_ID'];

  static String clientId =
      '26gd072a3jrqsjubrmaj0r4nr3'; //DotEnv().env['COGNITO_CLIENT_ID'];

  //final log = getLogger('CognitoService');
  final userPool = CognitoUserPool(userPoolId, clientId);
  CognitoUserSession userSession;
  // final _userProvider = Provider.of<UserProvider>(context, listen: true);

  CognitoService._privateConstructor();
  static final CognitoService instance =
      new CognitoService._privateConstructor();

  Future<Map<String, Object>> refreshAuth(
      CognitoUser cognitoUser, String refreshToken) async {
    CognitoRefreshToken cognitoRefreshToken =
        new CognitoRefreshToken(refreshToken);
    try {
      CognitoUserSession refreshResponse =
          await cognitoUser.refreshSession(cognitoRefreshToken);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'accessToken', refreshResponse.getAccessToken().getJwtToken());
      prefs.setString(
          'refreshToken', refreshResponse.getRefreshToken().getToken());
      return {'status': true, 'data': refreshResponse};
    } catch (e) {
      return {'status': false};
    }
  }

  Future<void> logoutUser(CognitoUser cognitoUser) async {
    await cognitoUser.signOut();
  }

  Future<Map<String, Object>> deleteUser(CognitoUser cognitoUser) async {
    //log.i('deleteUser | cognitoUser: $cognitoUser');
    bool userDeleted = false;
    try {
      userDeleted = await cognitoUser.deleteUser();
      //DELETE FROM DATABASE TOO
      //DELETE SHARED PREFERENCES
      //CLEAR PROVIDERS
      if (userDeleted == true) {
        return {'status': true, 'data': 'User successfully deleted'};
      } else {
        throw Error;
      }
    } catch (e) {
      //log.e(e);
      return {'status': false, 'data': e};
    }
  }

  Future<Map<String, Object>> registerUser(
      String username, String password) async {
    //log.i('registerUser | username: $username password: *******');
    CognitoUserPoolData data;
    try {
      data = await userPool.signUp('+1$username', password);
      //log.i(data);
    } catch (e) {
      //log.e(e);
      return {'status': false, 'message': 'ERROR', 'error': e};
    }
    if (data.user != null) {
      return {'status': true};
    } else {
      return {'status': false, 'message': 'REGISTRATION_FAILED'};
    }
  }

  Future<Map<String, Object>> forgotPassword(String username) async {
    //log.i('forgotPassword | username: $username');
    final cognitoUser = CognitoUser(username, userPool);
    var data;
    try {
      data = await cognitoUser.forgotPassword();
      //log.d(data);
      return {'status': true, 'cognitoUser': cognitoUser};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, Object>> confirmPassword(
      CognitoUser cognitoUser, String otp, String password) async {
    bool passwordConfirmed = false;
    try {
      passwordConfirmed = await cognitoUser.confirmPassword(otp, password);
      if (passwordConfirmed == true) {
        return {'status': true};
      } else {
        throw Error();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, Object>> confirmUser(
      String username, String confirmationCode) async {
    final cognitoUser = CognitoUser(username, userPool);
    bool registrationConfirmed = false;
    try {
      registrationConfirmed =
          await cognitoUser.confirmRegistration(confirmationCode);
      if (registrationConfirmed == false) {
        throw OTPException('Failed to verify OTP');
      } else {
        return {'status': true, 'cognitoUser': cognitoUser};
      }
    } catch (e) {
      //log.e(e);
      throw OTPException('Failed to verify OTP');
    }
  }

  Future<Map<String, Object>> getUserAttributes(CognitoUser cognitoUser) async {
    List<CognitoUserAttribute> attributes;
    Map<String, Object> returnMap = {'status': null};
    try {
      attributes = await cognitoUser.getUserAttributes();
      attributes.forEach((attribute) {
        if (attribute.getName() == 'custom:realUserId') {
          //log.i(attribute.getName());
          //log.i(attribute.getValue());
          returnMap = {'status': true, 'data': attribute.getValue()};
        }
      });
      if (returnMap['status'] != null) {
        return returnMap;
      } else {
        throw GetUserAttributeException('No attributes found');
      }
    } catch (e) {
      //log.e(e);
      rethrow;
    }
  }

  Future<Map<String, Object>> addUserAttributes(
      CognitoUser cognitoUser, String uid) async {
    try {
      final List<CognitoUserAttribute> attributes = [];
      attributes
          .add(CognitoUserAttribute(name: 'custom:realUserId', value: '$uid'));

      bool attributeUpdated = await cognitoUser.updateAttributes(attributes);
      if (attributeUpdated == true) {
        return {'status': true};
      } else {
        throw AddUserAttributeException('Failed to add user attribute');
      }
    } catch (e) {
      //log.e('ERROR: $e');
      return {'status': false, 'message': 'ATTRIBUTES', 'error': e};
    }
  }

  resendCode(String username, String password) async {
    final cognitoUser = CognitoUser('+1$username', userPool);
    try {
      final status = await cognitoUser.resendConfirmationCode();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, Object>> signInUser(
      String username, String password) async {
    //log.i("userPoolId | $userPoolId");
    //log.i('signInUser | phonenumber: $username password: *******');

    final authDetails =
        AuthenticationDetails(username: username, password: password);
    final cognitoUser = CognitoUser(username, userPool);
    final prefs = await SharedPreferences.getInstance();
    try {
      userSession = await cognitoUser.authenticateUser(authDetails);
    } on CognitoUserNewPasswordRequiredException catch (e) {
      // handle New Password challenge
    } on CognitoUserMfaRequiredException catch (e) {
      return {'status': false, 'message': 'MFA_NEEDED', 'error': e};
      // handle SMS_MFA challenge
    } on CognitoUserSelectMfaTypeException catch (e) {
      // handle SELECT_MFA_TYPE challenge
    } on CognitoUserMfaSetupException catch (e) {
      // handle MFA_SETUP challenge
    } on CognitoUserTotpRequiredException catch (e) {
      // handle SOFTWARE_TOKEN_MFA challenge
    } on CognitoUserCustomChallengeException catch (e) {
      // handle CUSTOM_CHALLENGE challenge
    } on CognitoUserConfirmationNecessaryException catch (e) {
      // handle User Confirmation Necessary
    } on CognitoClientException catch (e) {
      //log.e(e);
      rethrow;
    } catch (e) {
      //log.e(e);
      rethrow;
    }
    prefs.setString('accessToken', userSession.getAccessToken().getJwtToken());
    prefs.setString('refreshToken', userSession.getRefreshToken().getToken());
    return {
      'status': true,
      'message': 'Success',
      'cognitoUser': cognitoUser,
      'cognitoSession': userSession
    };
  }
}
