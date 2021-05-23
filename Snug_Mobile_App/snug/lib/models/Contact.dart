class Contact {
  final String name, phoneNumber;

  Contact({this.name, this.phoneNumber});

  //used when adding row to db
  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>();
    map['phone_number'] = phoneNumber;
    map['name'] = name;
    return map;
  }

  //used when converting a row into an object
  factory Contact.fromMap(Map<String, dynamic> data) =>
      new Contact(phoneNumber: data['phone_number'], name: data['name']);
}
