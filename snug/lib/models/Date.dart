import 'package:snug/models/User.dart';

class Date {
  String dateStart, dateEnd, photoReference, placeName, dateId;
  User who;
  Map<String, dynamic> trusted, dateLocation;

  Date(
      {this.who,
      this.dateStart,
      this.dateEnd,
      this.dateLocation,
      this.photoReference,
      this.placeName,
      this.trusted,
      this.dateId});

  Map<String, dynamic> toMapWithoutId() {
    final map = new Map<String, dynamic>();
    map['who'] = who;
    map['user_2'] = who.uid;
    map['date_start'] = dateStart.toString();
    map['date_end'] = dateEnd.toString();
    map['date_location'] = dateLocation;
    map['google_photo_reference'] = photoReference;
    map['place_name'] = placeName;
    map['trusted_contacts'] = trusted;
    return map;
  }

  Map<String, dynamic> toMapWithId() {
    final map = new Map<String, dynamic>();
    map['who'] = who;
    map['user_2'] = who.uid;
    map['date_start'] = dateStart.toString();
    map['date_end'] = dateEnd.toString();
    map['date_location'] = dateLocation;
    map['google_photo_reference'] = photoReference;
    map['place_name'] = placeName;
    map['trusted_contacts'] = trusted;
    map['date_id'] = dateId;
    return map;
  }

  factory Date.fromMap(Map<String, dynamic> data) => new Date(
      who: data['who'],
      dateStart: data['date_start'],
      dateEnd: data['date_end'],
      dateLocation: data['date_location'],
      photoReference: data['google_photo_reference'],
      placeName: data['place_name'],
      trusted: data['trusted_contacts'],
      dateId: data['date_id'].toString());
}
