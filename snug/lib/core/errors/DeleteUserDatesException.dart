class DeleteUserDatesException implements Exception {
  String _message;

  DeleteUserDatesException([String message = 'Error deleting user dates']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
