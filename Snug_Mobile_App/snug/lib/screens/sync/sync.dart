import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/screens/navigation/MainPage.dart';
import 'package:snug/services/sync/sync_contacts.dart';
import 'package:snug/services/sync/sync_dates.dart';
import 'package:snug/services/sync/sync_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncScreen extends StatefulWidget {
  @override
  _SyncScreenState createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  String _loadingMessage = '';
  final log = getLogger('SyncScreen');

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    setState(() {
      _loadingMessage = 'Loading your profile';
    });

    SharedPreferences _preferences = await SharedPreferences.getInstance();
    final _userId = _preferences.getString('uid');

    var userResponse = await syncUser(_userId, context);
    if (userResponse['status'] == true) {
      log.i('Successfully synced user');
    } else {
      //toast user that we couldn't sync their data
      log.w('Failed to sync user. Try again');
    }
    setState(() {
      _loadingMessage = 'Loading your trusted contacts';
    });
    var contactResponse =
        await syncContact(userResponse['trusted_contacts'], context);
    if (contactResponse['status'] == true) {
      log.i('Successfully synced trusted contacts');
    } else {
      //toast user that we couldn't sync their contacts
      log.w('Failed to sync trusted contacts. Try again');
      //SHOULD WE TELL THE USER THAT THEY CAN JUST REMAKE THEIR CONTACTS???
    }
    setState(() {
      _loadingMessage = 'Loading your current dates';
    });
    var datesResponse = await syncDates(_userId, context);
    if (datesResponse['status'] == true) {
      log.i('Successfully synced dates');
    } else {
      //toast user that we couldn't sync their dates
      //MAYBE MAKE A COOL LOADING ANIMATION WITH CHECKS AND Xes
      log.w('Failed to sync dates. Try again.');
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Container(
              child: Image.asset('assets/image/logo1.png',
                  fit: BoxFit.contain, height: 50),
            )),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Header(
                  //     child: Image.asset('assets/image/logo1.png',
                  //         fit: BoxFit.contain, height: 50)),
                  Text('$_loadingMessage'),
                  SizedBox(height: 20),
                  CircularProgressIndicator()
                  // backgroundColor:
                  //     Theme.of(context).colorScheme.secondaryVariant),
                ],
              ),
            )));
  }
}
