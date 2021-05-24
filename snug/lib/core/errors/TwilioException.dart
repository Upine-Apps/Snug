class TwilioException implements Exception {
  String _message;

  TwilioException([String message = 'Twilio error']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
