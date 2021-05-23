class UpdateUserException implements Exception {
  String _message;

  UpdateUserException([String message = 'Error updating user']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
