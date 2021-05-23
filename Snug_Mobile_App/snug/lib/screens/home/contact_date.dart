import 'package:flutter/material.dart';
import 'package:snug/models/Date.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:provider/provider.dart';

class ContactDate extends StatefulWidget {
  @override
  _ContactDateState createState() => _ContactDateState();
}

class _ContactDateState extends State<ContactDate> {
  @override
  void initState() {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    currentDate = dateProvider.getRecentDate;
    currentDate.trusted = new Map<String, dynamic>();
  }

  Date currentDate;
  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getUsers();
  @override
  Widget build(BuildContext context) {
    final contactProvider =
        Provider.of<ContactProvider>(context, listen: false);

    final contactList = contactProvider.getContacts;
    return ListView.builder(
        itemCount: contactList.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
              color: Theme.of(context).colorScheme.secondaryVariant,
              child: new Container(
                  padding: new EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      new CheckboxListTile(
                        activeColor:
                            Theme.of(context).colorScheme.primaryVariant,
                        dense: true,
                        title: new Text(contactList[index].name,
                            style: TextStyle(
                                color: Theme.of(context).dividerColor)),
                        value: checkBoxListTileModel[index].isCheck,
                        onChanged: (bool val) {
                          itemChange(val, index);

                          //take values that were selected from the checklist
                        },
                      )
                    ],
                  )));
        });
  }

  void itemChange(bool val, int index) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    final contactProvider =
        Provider.of<ContactProvider>(context, listen: false);
    final contactList = contactProvider.getContacts;
    setState(() {
      checkBoxListTileModel[index].isCheck = val;
    });
    Map<String, dynamic> contactMap = {};
    int trustedCounter = 1;
    for (var i = 0; i < 5; i++) {
      if (checkBoxListTileModel[i].isCheck == true) {
        contactMap['trusted_${trustedCounter}'] = contactList[i].toMap();
        trustedCounter++;
      }
    }
    currentDate.trusted = contactMap;
    dateProvider.setRecentDate(currentDate);
  }
}

class CheckBoxListTileModel {
  bool isCheck;

  CheckBoxListTileModel({this.isCheck});

  static List<CheckBoxListTileModel> getUsers() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(isCheck: false),
      CheckBoxListTileModel(isCheck: false),
      CheckBoxListTileModel(isCheck: false),
      CheckBoxListTileModel(isCheck: false),
      CheckBoxListTileModel(isCheck: false),
    ];
  }
}
