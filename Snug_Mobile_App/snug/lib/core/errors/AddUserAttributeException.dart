class AddUserAttributeException implements Exception {
  String _message;

  AddUserAttributeException([String message = 'Error adding user attribute']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
