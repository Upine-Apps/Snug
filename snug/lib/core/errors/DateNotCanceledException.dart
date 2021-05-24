class DateNotCanceledException implements Exception {
  String _message;

  DateNotCanceledException([String message = 'Date not canceled']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
