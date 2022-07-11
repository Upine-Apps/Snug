class LocationPermissionException implements Exception {
  String _message;

  LocationPermissionException(
      [String message = 'Error with location permission']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
