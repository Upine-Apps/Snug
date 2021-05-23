class ContactException implements Exception {
  String _message;

  ContactException([String message = 'Contact error']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
