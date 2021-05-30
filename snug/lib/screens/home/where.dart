import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/models/place.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/MapProvider.dart';
import 'package:provider/provider.dart';

class Where extends StatefulWidget {
  @override
  _WhereState createState() => _WhereState();
}

class _WhereState extends State<Where> {
  Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription locationSubscription;
  Date currentDate;

  void checkPermissions(MapProvider mp) async {
    Position p = await mp.determinePosition();
    print(p);
  }

  @override
  void initState() {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    currentDate = dateProvider.getRecentDate;
    currentDate.dateLocation = new Map<String, dynamic>();

    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    locationSubscription = mapProvider.selectedLocation.stream.listen((place) {
      if (place != null) {
        _goToPlace(place);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    mapProvider.dispose();
    locationSubscription.cancel();
    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();
  String placeName;

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context, listen: true);
    // checkPermissions(mapProvider);
    return (mapProvider.currentLocation == null)
        ? Center(
            child: CircularProgressIndicator(),
          )
        // return SingleChildScrollView(
        : SingleChildScrollView(
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                    child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryVariant)),
                          suffixIcon: Icon(
                            Icons.search,
                            color:
                                Theme.of(context).colorScheme.secondaryVariant,
                          ),
                          hintText: 'Search Location',
                        ),
                        onChanged: (value) {
                          mapProvider.searchPlaces(value);
                        })),
              ),
              Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * .425,
                      color: Colors.black,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                              mapProvider.currentLocation.latitude,
                              mapProvider.currentLocation.longitude,
                            ),
                            zoom: 14),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController.complete(controller);
                        },
                      )),
                  if (mapProvider.searchResults != null &&
                      mapProvider.searchResults.length != 0) ...[
                    // does not work well on fresh start. line 55 is null
                    Container(
                      padding: EdgeInsets.all(0),
                      height: MediaQuery.of(context).size.height * .425,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.50),
                          backgroundBlendMode: BlendMode.darken),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * .4,
                        child: ListView.builder(
                          itemCount: mapProvider.searchResults.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                mapProvider.searchResults[index].description,
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                placeName = mapProvider
                                    .searchResults[index].description;
                                _controller.text = placeName;
                                mapProvider.setSelectedLocation(
                                    mapProvider.searchResults[index].placeId);
                              },
                            );
                          },
                        ))
                  ]
                ],
              )
            ]),
          );
  }

  Future<void> _goToPlace(Place place) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    // update current date with location information
    currentDate.dateLocation = {
      'x': place.geometry.location.lat,
      'y': place.geometry.location.lng
    };
    currentDate.photoReference = place.photos.photoReference;
    currentDate.placeName = place.placeName;
    dateProvider.setRecentDate(currentDate);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            place.geometry.location.lat,
            place.geometry.location
                .lng), // Lat and Lng values of the selected location
        zoom: 17)));
  }
}
