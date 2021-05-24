class DateNotSyncedException implements Exception {
  String _message;

  DateNotSyncedException([String message = 'Date failed to sync']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
