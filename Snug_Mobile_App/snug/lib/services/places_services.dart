import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:snug/models/PlaceSearch.dart';
import 'package:snug/models/place.dart';

class PlacesService {
  final key = 'AIzaSyDMT-oJtKYtCTGHQmlIS7vNk7scGSGgSVw';
  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    print(search);
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=establishment&key=$key';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['predictions'] as List;

    return jsonResult.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?key=$key&place_id=$placeId';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;

    return Place.fromJson(jsonResult);
  }
}
