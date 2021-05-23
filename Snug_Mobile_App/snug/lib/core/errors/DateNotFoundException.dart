class DateNotFoundException implements Exception {
  String _message;

  DateNotFoundException([String message = 'Date not found']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
