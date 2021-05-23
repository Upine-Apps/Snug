class ProfileException implements Exception {
  String _message;

  ProfileException([String message = 'Profile error']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
