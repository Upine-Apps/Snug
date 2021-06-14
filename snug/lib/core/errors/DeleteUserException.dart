class DeleteUserException implements Exception {
  String _message;

  DeleteUserException([String message = 'Error deleting user']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
