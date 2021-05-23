class AddUserException implements Exception {
  String _message;

  AddUserException([String message = 'Error adding user']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
