class AddDateException implements Exception {
  String _message;

  AddDateException([String message = 'Error adding date']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
