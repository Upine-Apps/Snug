class GetUserAttributeException implements Exception {
  String _message;

  GetUserAttributeException([String message = 'Error getting user attribute']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
