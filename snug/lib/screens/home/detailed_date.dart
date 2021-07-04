import 'package:emojis/emoji.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:snug/core/errors/DateNotCanceledException.dart';
import 'package:snug/core/errors/DateNotMarkedSafeException.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';

import 'package:snug/models/Contact.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/screens/navigation/MainPage.dart';
import 'package:snug/services/conversion.dart';
import 'package:snug/services/remote_db_service.dart';
import 'package:provider/provider.dart';
import 'package:snug/custom_widgets/header_with_back_button.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailDate extends StatefulWidget {
  final int someIndex;

  DetailDate({this.someIndex});
  @override
  _DetailDateState createState() => _DetailDateState();
}

class _DetailDateState extends State<DetailDate> {
  List<Contact> trusted;
  List<Marker> _markers = <Marker>[];
  final Conversion _conversion = Conversion();
  final log = getLogger('DetailDate');
  String _endStatus;
  Emoji somethingWentWrong = Emoji.byChar(Emojis.flushedFace);

  _convertDate(String dateTime) {
    String period;
    String hour;
    String min;

    DateTime realDateTime = DateTime.parse(dateTime);
    DateTime actualDateTime = realDateTime.toLocal();
    actualDateTime.hour >= 12 ? period = "PM" : period = "AM";
    actualDateTime.hour > 12
        ? hour = (actualDateTime.hour - 12).toString()
        : hour = actualDateTime.hour.toString();
    if (actualDateTime.hour == 0) {
      hour = 12.toString();
    }

    actualDateTime.minute < 10
        ? min = "0${actualDateTime.minute}"
        : min = "${actualDateTime.minute}";

    return "${actualDateTime.month}/${actualDateTime.day}/${actualDateTime.year}";
  }

  _convertTime(String dateTime) {
    String period;
    String hour;
    String min;

    DateTime realDateTime = DateTime.parse(dateTime);
    DateTime actualDateTime = realDateTime.toLocal();
    actualDateTime.hour >= 12 ? period = "PM" : period = "AM";
    actualDateTime.hour > 12
        ? hour = (actualDateTime.hour - 12).toString()
        : hour = actualDateTime.hour.toString();
    if (actualDateTime.hour == 0) {
      hour = 12.toString();
    }

    actualDateTime.minute < 10
        ? min = "0${actualDateTime.minute}"
        : min = "${actualDateTime.minute}";

    return "$hour:$min $period";
  }

  _converedTimeInDateTime(String dateTime) {
    DateTime realDateTime = DateTime.parse(dateTime);
    DateTime actualDateTime = realDateTime.toLocal();
    return actualDateTime;
  }

  @override
  bool dateExist = true;
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context, listen: true);
    final contactProvider = Provider.of<ContactProvider>(context, listen: true);
    int someIndex = widget.someIndex;
    Date _currentDate = dateProvider.getCurrentDates[someIndex];
    // ADDING A MARKER TO GOOGLE MAPS
    _markers.add(Marker(
        markerId: MarkerId('someId'),
        position: LatLng(
            _currentDate.dateLocation['x'], _currentDate.dateLocation['y']),
        infoWindow: InfoWindow(title: _currentDate.placeName)));

    // ADDING A MARKER TO GOOGLE MAPS
    return new WillPopScope(
      onWillPop: () async => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage())),
      child: LoaderOverlay(
        overlayColor: Theme.of(context).colorScheme.secondaryVariant,
        overlayOpacity: 0.8,
        useDefaultLoading: false,
        overlayWidget: Center(
            child: SpinKitWave(
                color: Theme.of(context).colorScheme.secondary, size: 50)),
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            body: SafeArea(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ])),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * .025,
                                  right:
                                      MediaQuery.of(context).size.width * .025),
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .02),
                                  child: HeaderWithBackButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MainPage()));
                                      },
                                      child: Image.asset(
                                        'assets/image/logo1.png',
                                        fit: BoxFit.contain,
                                        height: 50,
                                      )),
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * .025,
                                right:
                                    MediaQuery.of(context).size.width * .025),
                            child: Container(
                                width: MediaQuery.of(context).size.width * .95,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant,
                                    elevation: 10.0,
                                    child: Container(

                                        //Container for everything that is going in the who card
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .95,
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${_currentDate.who.first_name} ${_currentDate.who.last_name}',
                                              style: TextStyle(
                                                  fontSize: 28,
                                                  color: Theme.of(context)
                                                      .dividerColor),
                                            ))))),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * .025,
                                  right:
                                      MediaQuery.of(context).size.width * .025),
                              child: Row(children: <Widget>[
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        (.5),
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryVariant,
                                        elevation: 10.0,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .225,
                                                          child: Text('Gender:',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor))),
                                                      Container(
                                                          child: Text(
                                                        _conversion.convertSex(
                                                            _currentDate
                                                                .who.sex),
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor),
                                                      ))
                                                    ],
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .225,
                                                          child: Text(
                                                            'Race:',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor),
                                                          )),
                                                      Container(
                                                          child: Expanded(
                                                        child: Text(
                                                          _conversion
                                                              .convertRace(
                                                                  _currentDate
                                                                      .who
                                                                      .race),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor),
                                                        ),
                                                      ))
                                                    ],
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .225,
                                                          child: Text(
                                                            'Hair Color:',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor),
                                                          )),
                                                      Container(
                                                          child: Text(
                                                        _conversion.convertHair(
                                                            _currentDate
                                                                .who.hair),
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor),
                                                      ))
                                                    ],
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .225,
                                                          child: Text(
                                                            'Eye Color:',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor),
                                                          )),
                                                      Container(
                                                          child: Text(
                                                        _conversion.convertEye(
                                                            _currentDate
                                                                .who.eye),
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor),
                                                      ))
                                                    ],
                                                  )),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .225,
                                                          child: Text(
                                                            'Height:',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor),
                                                          )),
                                                      Container(
                                                          child: Text(
                                                        _conversion
                                                            .convertHeight(
                                                                _currentDate
                                                                    .who.ft,
                                                                _currentDate
                                                                    .who.inch),
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor),
                                                      ))
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ))),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        (.45),
                                    child: GestureDetector(
                                      onTap: () {
                                        launch(
                                            "tel:${_currentDate.who.phone_number}");
                                      },
                                      child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant,
                                          elevation: 10.0,
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .01),
                                                  child: Container(
                                                      child: Icon(
                                                    Icons.phone,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  )),
                                                ),
                                                Container(
                                                    child: Text(
                                                  "(" +
                                                      _currentDate
                                                          .who.phone_number
                                                          .substring(0, 3) +
                                                      ") - " +
                                                      _currentDate
                                                          .who.phone_number
                                                          .substring(3, 6) +
                                                      " - " +
                                                      _currentDate
                                                          .who.phone_number
                                                          .substring(6, 10),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary),
                                                ))
                                              ],
                                            ),
                                          )),
                                    ))
                              ])),
                          Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * .025,
                                  right:
                                      MediaQuery.of(context).size.width * .025),
                              child: Container(
                                width: MediaQuery.of(context).size.width * .95,
                                height: MediaQuery.of(context).size.height * .5,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant,
                                    elevation: 10.0,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .95,
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                            ),
                                            child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: GoogleMap(
                                                  markers:
                                                      Set<Marker>.of(_markers),
                                                  zoomControlsEnabled: false,
                                                  mapType: MapType.normal,
                                                  initialCameraPosition: CameraPosition(
                                                      target: LatLng(
                                                          _currentDate
                                                                  .dateLocation[
                                                              'x'],
                                                          _currentDate
                                                                  .dateLocation[
                                                              'y']),
                                                      zoom: 14),
                                                ))))),
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * .025,
                                  right:
                                      MediaQuery.of(context).size.width * .025),
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * .95,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (.95 / 2),
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant,
                                              elevation: 10.0,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                            Icons
                                                                .flight_takeoff,
                                                            size: 35,
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .15,
                                                              child: Text(
                                                                'Day:',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .dividerColor),
                                                              )),
                                                          Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              _convertDate(
                                                                  _currentDate
                                                                      .dateStart),
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .15,
                                                            child: Text(
                                                              'Time:',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor),
                                                            )),
                                                        Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            _convertTime(
                                                                _currentDate
                                                                    .dateStart),
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ))),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (.95 / 2),
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant,
                                              elevation: 10.0,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          Icons.flight_land,
                                                          size: 35,
                                                          color:
                                                              Theme.of(context)
                                                                  .dividerColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .01),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .15,
                                                              child: Text(
                                                                'Day:',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .dividerColor),
                                                              )),
                                                          Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              _convertDate(
                                                                  _currentDate
                                                                      .dateEnd),
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .15,
                                                            child: Text(
                                                              'Time:',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .dividerColor),
                                                            )),
                                                        Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            _convertTime(
                                                                _currentDate
                                                                    .dateEnd),
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .dividerColor),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )))
                                    ],
                                  ))),
                          Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * .025,
                                  right:
                                      MediaQuery.of(context).size.width * .025),
                              child: Container(
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: _currentDate.trusted.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return new GestureDetector(
                                            onTap: () {
                                              var trustedIndex =
                                                  "trusted_$index";
                                              launch(
                                                  "tel:${dateProvider.getCurrentDates[someIndex].trusted[trustedIndex].phone_number}");
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryVariant,
                                              elevation: 10.0,
                                              child: new Container(
                                                padding: new EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: <Widget>[
                                                    Text(
                                                      _currentDate.trusted[
                                                              'trusted_${index + 1}']
                                                          ['name'],
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Theme.of(
                                                                  context)
                                                              .dividerColor),
                                                    ),
                                                    Text(
                                                      "(" +
                                                          _currentDate.trusted[
                                                                  'trusted_${index + 1}']
                                                                  [
                                                                  'phone_number']
                                                              .substring(0, 3) +
                                                          ") - " +
                                                          _currentDate.trusted[
                                                                  'trusted_${index + 1}']
                                                                  [
                                                                  'phone_number']
                                                              .substring(3, 6) +
                                                          " - " +
                                                          _currentDate.trusted[
                                                                  'trusted_${index + 1}']
                                                                  [
                                                                  'phone_number']
                                                              .substring(6, 10),
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Theme.of(
                                                                  context)
                                                              .dividerColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )))),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .005,
                                bottom:
                                    MediaQuery.of(context).size.height * .01),
                            child: Container(
                                alignment: Alignment.center,
                                child: RaisedRoundedGradientButton(
                                  child: Text(
                                    _converedTimeInDateTime(
                                                _currentDate.dateStart)
                                            .isAfter(DateTime.now())
                                        ? _endStatus = 'Cancel Date'
                                        : _endStatus = 'Safe',
                                    style: TextStyle(
                                        color: Theme.of(context).dividerColor,
                                        fontSize: 18),
                                  ),
                                  onPressed: () async {
                                    if (_endStatus == 'Cancel Date') {
                                      try {
                                        Map<String, dynamic> cancelResponse =
                                            await RemoteDatabaseHelper.instance
                                                .cancelDate(
                                                    _currentDate.dateId);
                                        if (cancelResponse['status'] == true) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoadingScreen(
                                                        someIndex: someIndex,
                                                      )));
                                        } else {
                                          throw DateNotCanceledException(
                                              'Failed to cancel date');
                                        }
                                      } catch (e) {
                                        log.e(
                                            'Failed to cancel date. Caught exception: $e');
                                        CustomToast.showDialog(
                                            'Failed to cancel date. Please try again later $somethingWentWrong',
                                            context,
                                            Toast.BOTTOM);
                                      }
                                    } else {
                                      try {
                                        Map<String, dynamic> markSafeResponse =
                                            await RemoteDatabaseHelper.instance
                                                .markDateSafe(
                                                    _currentDate.dateId);
                                        if (markSafeResponse['status'] ==
                                            true) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoadingScreen(
                                                        someIndex: someIndex,
                                                      )));
                                        } else {
                                          throw DateNotMarkedSafeException(
                                              'Failed to mark safe');
                                        }
                                      } catch (e) {
                                        log.e(
                                            'Failed to mark date safe. Caught exception: $e');
                                        CustomToast.showDialog(
                                            'Failed to mark date safe. Please try again later $somethingWentWrong',
                                            context,
                                            Toast.BOTTOM);
                                      }
                                    }

                                    // if mark safe COPY ALL THAT AND CHANGE FUNCTION

                                    //ADDED DELETE DATE FUNCTION. TEST THE UI AND FUNCTIONALITY
                                  },
                                )),
                          )
                        ],
                      ),
                    )))),
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final int someIndex;
  LoadingScreen({this.someIndex});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.loaderOverlay.show();
      await Future.delayed(Duration(seconds: 1), () {
        dateProvider.removeDate(widget.someIndex);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainPage(
                      fromAddDate: true,
                    )));
      });
    });
    return LoaderOverlay(
      overlayColor: Theme.of(context).colorScheme.secondaryVariant,
      overlayOpacity: 0.8,
      useDefaultLoading: false,
      overlayWidget: Center(
          child: SpinKitWave(
              color: Theme.of(context).colorScheme.secondary, size: 50)),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ])),
          )),
    );
  }
}
