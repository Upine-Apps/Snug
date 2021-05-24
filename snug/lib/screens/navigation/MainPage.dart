import 'package:flutter/material.dart';
import 'package:gradient_bottom_navigation_bar/gradient_bottom_navigation_bar.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/screens/contacts/contact.dart';
import 'package:snug/screens/home/home.dart';
import 'package:snug/screens/profile/profile.dart';
import 'package:snug/screens/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class MainPage extends StatefulWidget {
  final bool firstContact;
  MainPage({this.firstContact});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey home = GlobalKey();
  final List<Widget> _pages = [
    ShowCaseWidget(
        onFinish: () async {
          SharedPreferences _homeTutorial =
              await SharedPreferences.getInstance();
          _homeTutorial.setBool('homeTutorial', false);
        },
        builder: Builder(
          builder: (_) => Home(),
        )),
    ShowCaseWidget(
        onFinish: () async {
          SharedPreferences _contactTutorial =
              await SharedPreferences.getInstance();
          _contactTutorial.setBool('contactTutorial', false);

          _contactTutorial.setBool('deletContact', false);
        },
        builder: Builder(
          builder: (_) => Contact(),
        )),
    ShowCaseWidget(
      onFinish: () async {
        SharedPreferences _settingsTutorial =
            await SharedPreferences.getInstance();
        _settingsTutorial.setBool('settingsTutorial', false);
      },
      builder: Builder(
        builder: (_) => SettingScreen(),
      ),
    ),
    ShowCaseWidget(
        onFinish: () async {
          SharedPreferences _profileTutorial =
              await SharedPreferences.getInstance();
          _profileTutorial.setBool('profileTutorial', false);
        },
        builder: Builder(
          builder: (_) => ProfilePage(),
        )),
  ];

  PageController pageController;

  int _selectedIndex = 0;
  final log = getLogger('MainPage');

  @override
  void initState() {
    super.initState();
    log.i('OnMainPage');
    pageController = PageController();

    if (widget.firstContact == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.jumpToPage(1);
        }
      });
    }
  }

  // @override
  // void dispose() {
  //   pageController.dispose();
  // }

  _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: _pages,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: GradientBottomNavigationBar(
        backgroundColorEnd: Theme.of(context).colorScheme.secondaryVariant,
        backgroundColorStart: Theme.of(context).colorScheme.primaryVariant,
        currentIndex: _selectedIndex,
        onTap: _onTapped,
        items: [
          BottomNavigationBarItem(
            title: Text(
              'Home',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            // label: "Home",
            backgroundColor: Theme.of(context).colorScheme.secondary,
            icon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          BottomNavigationBarItem(
            title: Text(
              'Contacts',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            // label: "Contacts",
            backgroundColor: Theme.of(context).colorScheme.secondary,
            icon: Icon(
              Icons.contacts_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          BottomNavigationBarItem(
            title: Text(
              'Settings',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            // label: "Settings",
            backgroundColor: Theme.of(context).colorScheme.secondary,
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          BottomNavigationBarItem(
            title: Text(
              'Profile',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            // label: "Profile",
            backgroundColor: Theme.of(context).colorScheme.secondary,
            icon: CircleAvatar(
                backgroundImage: new AssetImage('assets/image/pug.jpg')),
          ),
        ],
      ),
    );
  }
}
