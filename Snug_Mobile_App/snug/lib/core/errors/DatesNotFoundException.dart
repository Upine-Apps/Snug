class DatesNotFoundException implements Exception {
  String _message;

  DatesNotFoundException([String message = 'Date error']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
