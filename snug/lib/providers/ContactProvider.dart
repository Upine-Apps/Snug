import 'package:flutter/material.dart';
import 'package:snug/services/remote_db_service.dart';
import '../models/Contact.dart';

class ContactProvider extends ChangeNotifier {
  List<Contact> _contacts = new List<Contact>();
  List<Contact> get getContacts {
    print('in provider getContacts');
    return _contacts;
  }

  void addContact(String name, String phone, [userId]) {
    Contact contact = new Contact(name: name, phoneNumber: phone);
    _contacts.add(contact);
    if (userId != null) {
      updateRemoteDb(userId);
    }
    notifyListeners();
  }

  //send updated contact list to remote database. Will add names in here when remote can handle
  void updateRemoteDb(String userId) {
    print('in provider updateRemoteDb');
    RemoteDatabaseHelper.instance.addTrustedContacts(_contacts, userId);
  }

  void removeContact(int index, String userId) {
    print('in provider removeContact');
    _contacts.removeAt(index);
    updateRemoteDb(userId);
    notifyListeners();
  }

  void removeAllContacts() {
    _contacts = <Contact>[]; //new syntax yuh not deprecated
    notifyListeners();
  }
}
