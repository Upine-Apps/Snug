import 'package:flutter/material.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:provider/provider.dart';
import 'package:snug/screens/navigation/MainPage.dart';
import 'package:snug/screens/sync/sync.dart';

class VerifyExit extends StatefulWidget {
  @override
  _VerifyExitState createState() => _VerifyExitState();
}

class _VerifyExitState extends State<VerifyExit> {
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    return AlertDialog(
        title: Text('Return to home?',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          // side: BorderSide(
          //   color: Theme.of(context).dividerColor,
          //   width: .5,
          // )
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryVariant,

        // content: Text('Yes'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              //deletes the last date created
              dateProvider.getCurrentDates.removeLast();
              // Navigator.of(context).pop(true);
              // Navigator.of(context).pop(true);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            },
            // onPressed: () => Navigator.pushReplacement(
            //     context, MaterialPageRoute(builder: (context) => MainPage())),
            child: Text('Yes',
                style: TextStyle(color: Theme.of(context).dividerColor)),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('No',
                style: TextStyle(color: Theme.of(context).dividerColor)),
          )
        ]);
  }
}
