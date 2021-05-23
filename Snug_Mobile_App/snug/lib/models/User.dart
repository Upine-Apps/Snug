class User {
  String first_name,
      last_name,
      dob,
      error,
      sex,
      race,
      eye,
      hair,
      ft,
      inch,
      street,
      city,
      state,
      zip,
      phone_number,
      temp,
      uid;
  User({
    this.uid,
    this.first_name,
    this.last_name,
    this.dob,
    this.error,
    this.sex,
    this.race,
    this.eye,
    this.hair,
    this.ft,
    this.inch,
    this.street,
    this.city,
    this.state,
    this.zip,
    this.phone_number,
    this.temp,
  });

  Map<String, dynamic> toMapWithId() {
    final map = new Map<String, dynamic>();
    map['first_name'] = first_name;
    map['last_name'] = last_name;
    map['dob'] = dob;
    map['sex'] = sex;
    map['race'] = race;
    map['eye'] = eye;
    map['hair'] = hair;
    map['ft'] = ft;
    map['inch'] = inch;
    map['street'] = street;
    map['city'] = city;
    map['state'] = state;
    map['zip'] = zip;
    map['user_id'] = uid;
    map['phone_number'] = phone_number;
    map['temporary'] = temp;
    return map;
  }

  Map<String, dynamic> toMapWithoutId() {
    final map = new Map<String, dynamic>();
    map['first_name'] = first_name;
    map['last_name'] = last_name;
    map['dob'] = dob;
    map['sex'] = sex;
    map['race'] = race;
    map['eye'] = eye;
    map['hair'] = hair;
    map['ft'] = ft;
    map['inch'] = inch;
    map['street'] = street;
    map['city'] = city;
    map['state'] = state;
    map['zip'] = zip;
    map['phone_number'] = phone_number;
    map['temporary'] = temp;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> data) => new User(
      first_name: data['first_name'],
      last_name: data['last_name'],
      dob: data['dob'],
      sex: data['sex'],
      race: data['race'],
      eye: data['eye'],
      hair: data['hair'],
      ft: data['ft'].toString(),
      inch: data['inch'].toString(),
      street: data['street'],
      city: data['city'],
      state: data['state'],
      zip: data['zip'],
      uid: data['user_id'].toString(),
      phone_number: data['phone_number'].toString(),
      temp: data['temporary'].toString());
}
