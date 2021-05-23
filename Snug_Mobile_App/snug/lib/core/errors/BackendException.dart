class BackendException implements Exception {
  String _message;

  BackendException([String message = 'Backend error']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
