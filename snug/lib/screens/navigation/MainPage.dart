import 'package:flutter/material.dart';
import 'package:gradient_bottom_navigation_bar/gradient_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/contacts/contact.dart';
import 'package:snug/screens/home/home.dart';
import 'package:snug/screens/profile/profile.dart';
import 'package:snug/screens/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:toast/toast.dart';
import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';

class MainPage extends StatefulWidget {
  bool firstContact;
  bool fromAddDate;
  MainPage({this.firstContact, this.fromAddDate});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey home = GlobalKey();
  final List<Widget> _pages = [
    Home(),
    Contact(),
    SettingScreen(),
    ProfilePage(),
  ];
  String picture;

  PageController pageController;

  int _selectedIndex = 0;

  Emoji heart = Emoji.byChar(Emojis.redHeart);
  //final log = getLogger('MainPage');

  @override
  void initState() {
    super.initState();
    //log.i('OnMainPage');
    pageController = PageController();

    setProfilePic();
    if (widget.fromAddDate == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomToast.showDialog(
            'Glad you\'re safe! $heart', context, Toast.BOTTOM);
      });
    }
  }

  moveToContactScreen() {}

  setProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('profilePicture') != null) {
      setState(() {
        picture = prefs.getString('profilePicture');
      });
    } else {
      setState(() {
        picture = 'assets/image/pug.jpg';
      });
    }
  }

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
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    if (widget.firstContact == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print(pageController.hasClients);
        if (pageController.hasClients) {
          pageController.jumpToPage(1);
          widget.firstContact = false;
        }
      });
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: PageView(
          children: _pages,
          controller: pageController,
          onPageChanged: onPageChanged,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
          currentIndex: _selectedIndex,
          onTap: _onTapped,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              // activeIcon:
              title: Text(
                'Home',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              // label: "Home",
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              icon: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                'Contacts',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              // label: "Contacts",
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              icon: Icon(
                Icons.contacts_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                'Settings',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              // label: "Settings",
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            BottomNavigationBarItem(
              title: Text(
                'Profile',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              // label: "Profile",
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              icon: CircleAvatar(
                  backgroundImage: new AssetImage(
                      userProvider.getProfilePic == null
                          ? picture
                          : userProvider.getProfilePic)),
            ),
          ],
        ),
      ),
    );
  }
}
