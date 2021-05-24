import 'package:snug/models/geometry.dart';
import 'package:snug/models/photo.dart';

class Place {
  final Geometry geometry;
  final String name;
  final String vicinity;
  final Photo photos;
  final String placeName;

  Place({this.geometry, this.name, this.vicinity, this.photos, this.placeName});

  factory Place.fromJson(Map<String, dynamic> parsedJson) {
    return Place(
        placeName: parsedJson['name'],
        photos: Photo.fromJson(parsedJson['photos'][1]),
        geometry: Geometry.fromJson(parsedJson['geometry']),
        name: parsedJson['formatted_address'],
        vicinity: parsedJson['vicinity']);
  }
}
