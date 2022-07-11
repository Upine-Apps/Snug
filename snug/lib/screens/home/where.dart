import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/models/place.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/LogProvider.dart';
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
  bool gotLocation = false;
  //final log = getLogger('where');
  @override
  void initState() {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    currentDate = dateProvider.getRecentDate;
    currentDate.dateLocation = new Map<String, dynamic>();

    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Where Section', logProvider.getLogPath);

    locationSubscription = mapProvider.selectedLocation.stream.listen((place) {
      if (place != null) {
        log.d('_goToPlace()');
        _goToPlace(place, logProvider);
      }
    });

    super.initState();
    getLocation();
  }

  getLocation() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    await mapProvider.determinePosition();
    //log.i(mapProvider.currentLocation);
    if (mapProvider.currentLocation != null) {
      setState(() {
        gotLocation = true;
      });
    }
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
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('Where Section', logProvider.getLogPath);
    return (gotLocation == false)
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
                          color: Theme.of(context).colorScheme.secondaryVariant,
                        ),
                        hintText: 'Search Location',
                      ),
                      onChanged: (value) {
                        mapProvider.searchPlaces(value);
                      },
                      onTap: () {
                        log.i('Searching for location');
                        log.d('mapProvider.searchPlaces');
                      }),
                ),
              ),
              Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * .5,
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
                      height: MediaQuery.of(context).size.height * .5,
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
                                log.i('Location picked');
                                log.d('mapProvider.setSelectedLocation');
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
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

  Future<void> _goToPlace(Place place, LogProvider logProvider) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final log = getLogger('Where Section', logProvider.getLogPath);

    // update current date with location information
    currentDate.dateLocation = {
      'x': place.geometry.location.lat,
      'y': place.geometry.location.lng
    };
    currentDate.photoReference = place.photos.photoReference;
    currentDate.placeName = place.placeName;
    log.d('dateProvider.setRecentDate()');
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
