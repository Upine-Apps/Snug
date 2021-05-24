class DateNotMarkedSafeException implements Exception {
  String _message;

  DateNotMarkedSafeException([String message = 'Date not marked safe']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
