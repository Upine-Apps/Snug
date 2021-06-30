import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snug/core/errors/LocationPermissionException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/models/PlaceSearch.dart';
import 'package:snug/models/place.dart';
import 'package:snug/screens/home/geolocator_shit/geolocator_service.dart';
import 'package:snug/services/places_services.dart';

class MapProvider with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();
  final log = getLogger('mapProvider');
  //Variables
  Position currentLocation;
  List<PlaceSearch> searchResults;
  StreamController<Place> selectedLocation = StreamController<
      Place>.broadcast(); //broadcast lets you listen to the stream more than once

  // MapProvider() {}

  // setCurrentLocation() async {
  //   currentLocation = await geoLocatorService.getCurrentLocation();
  //   print(currentLocation);
  //   notifyListeners();
  // }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placesService.getPlace(placeId));
    searchResults = null;
    notifyListeners();
  }

  Future<LocationPermission> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw LocationPermissionException('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw LocationPermissionException(
          'Location permissions are permanently denied, cannot request permissions');
    }
    return permission;
  }

  determinePosition() async {
    try {
      final permissionCheck = await checkPermissions();
      if (permissionCheck == LocationPermission.always ||
          permissionCheck == LocationPermission.whileInUse) {
        // When we reach here, permissions are granted and we can
        // continue accessing the position of the device.
        currentLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        notifyListeners();
      } else {
        throw LocationPermissionException('Error getting permissions');
      }
    } catch (e) {
      log.e(e);
    }
  }

  @override
  dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
