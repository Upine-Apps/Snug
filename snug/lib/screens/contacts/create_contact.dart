import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/raised_rounded_gradient_button.dart';
import 'package:snug/models/User.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/navigation/MainPage.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class CreateContact extends StatefulWidget {
  @override
  _CreateContactState createState() => _CreateContactState();
}

class _CreateContactState extends State<CreateContact> {
  @override
  var _formKey = GlobalKey<FormState>();
  bool get wantKeepAlive => true;
  bool contactExist = false;

  String _phone;

  String _name;

  String _userId = '';

  final TextEditingController nameCtrl = new TextEditingController();

  final TextEditingController phoneCtrl = new TextEditingController();

  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    final contactList = Provider.of<ContactProvider>(context, listen: false);
    final profileUser = Provider.of<UserProvider>(context, listen: true);

    User _tempUser = profileUser.getUser;
    _userId = _tempUser.uid;
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
        backgroundColor: Colors.transparent,
        content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .375,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/image/contact_dark_background.png'
                            : 'assets/image/contact_light_background.png'),
                    fit: BoxFit.fill)),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Form(
                  child: Column(children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * .125,
                ),
                Container(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .05,
                      right: MediaQuery.of(context).size.width * .05,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onEditingComplete: () => node.nextFocus(),
                                  controller: nameCtrl,
                                  decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                      icon: Icon(Icons.person),
                                      labelText: 'Name'),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[a-zA-Z\\s]')),
                                  ],
                                  validator: (String val) {
                                    if (val.length > 30) {
                                      return "Ya got a shorter name?";
                                    }
                                  },
                                  onChanged: (val) {
                                    _name = val;
                                  }),
                              TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]+')),
                                  ],
                                  controller: phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant),
                                      icon: Icon(Icons.phone),
                                      labelText: 'Phone Number'),
                                  validator: (String val) {
                                    if (val.length != 10) {
                                      return "Enter a valid phone number";
                                    }
                                  },
                                  onChanged: (val) {
                                    _phone = val;
                                  }),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .0125),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .25,
                                      child: RaisedRoundedGradientButton(
                                        child: Text('Save',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .dividerColor)),
                                        onPressed: () {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());

                                          if (_formKey.currentState
                                              .validate()) {
                                            for (var checkContacts
                                                in contactList.getContacts) {
                                              if (checkContacts.phoneNumber ==
                                                  _phone) {
                                                setState(() {
                                                  contactExist = true;
                                                });
                                              }
                                            }
                                            if (contactExist == true) {
                                              CustomToast.showDialog(
                                                  "This contact already exists",
                                                  context,
                                                  Toast.BOTTOM);
                                            } else if (_name == null) {
                                              CustomToast.showDialog(
                                                  "Does this contact have a name?",
                                                  context,
                                                  Toast.BOTTOM);
                                            } else if (profileUser
                                                    .getUser.phone_number ==
                                                _phone) {
                                              CustomToast.showDialog(
                                                  'You\'re your own contact? ',
                                                  context,
                                                  Toast.BOTTOM);
                                            } else {
                                              contactList.addContact(
                                                  _name, _phone, _userId);

                                              if (contactList
                                                      .getContacts.length ==
                                                  1) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MainPage(
                                                            firstContact: true,
                                                          )),
                                                );
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            }
                                          }
                                        },
                                      )))
                            ],
                          ),
                        )))
              ])),
            )));
  }
}
