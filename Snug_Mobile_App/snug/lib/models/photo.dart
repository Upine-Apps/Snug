class Photo {
  final String photoReference;

  Photo({this.photoReference});

  factory Photo.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Photo(photoReference: parsedJson['photo_reference']);
  }
}
