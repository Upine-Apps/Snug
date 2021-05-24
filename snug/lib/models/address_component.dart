class AddressComponents {
  final String placeName;

  AddressComponents({this.placeName});
  factory AddressComponents.fromJson(Map<dynamic, dynamic> parsedJson) {
    return AddressComponents(placeName: parsedJson['long_name']);
  }
}
