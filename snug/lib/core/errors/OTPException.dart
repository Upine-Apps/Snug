class OTPException implements Exception {
  String _message;

  OTPException([String message = 'Error validating OTP']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
