class GetUserException implements Exception {
  String _message;

  GetUserException([String message = 'Error getting user: ']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
