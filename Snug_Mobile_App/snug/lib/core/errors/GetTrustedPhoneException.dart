class GetTrustedPhoneException implements Exception {
  String _message;

  GetTrustedPhoneException([String message = 'GetTrustedPhone error']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
