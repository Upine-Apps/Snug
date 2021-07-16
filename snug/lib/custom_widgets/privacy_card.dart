import 'package:flutter/material.dart';

class PrivacyCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final String body;
  PrivacyCard({this.title, this.icon, this.body});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .05),
        child: Container(
            child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                // color: Colors.red,
                width: MediaQuery.of(context).size.width * .9,
                child: Card(
                  color: Theme.of(context).colorScheme.secondaryVariant,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)),
                  elevation: 20,
                  child: Container(
                      height: MediaQuery.of(context).size.height * .625,
                      child: ListView(
                        children: <Widget>[
                          SizedBox(
                              height: MediaQuery.of(context).size.width * .2),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width * .1,
                                  left: MediaQuery.of(context).size.width * .1),
                              child: Text(
                                title,
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Theme.of(context).dividerColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.width * .075),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width * .1,
                                  left: MediaQuery.of(context).size.width * .1),
                              child: Text(
                                body,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context).dividerColor),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ),
            Align(
                child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    radius: MediaQuery.of(context).size.width * .125,
                    child: icon),
                alignment: Alignment.topCenter)
          ],
        )));
  }
}
