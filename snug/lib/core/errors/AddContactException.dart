class AddContactException implements Exception {
  String _message;

  AddContactException([String message = 'Error adding contacts']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
