import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share/share.dart';
import 'package:snug/custom_widgets/CustomToast.dart';
import 'package:snug/custom_widgets/customshowcase.dart';
import 'package:snug/custom_widgets/privacy_card.dart';
import 'package:snug/custom_widgets/topheader.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:snug/providers/DateProvider.dart';
import 'package:snug/providers/LogProvider.dart';
import 'package:snug/providers/UserProvider.dart';
import 'package:snug/screens/navigation/MainPage.dart';
import 'package:snug/screens/settings/settings.dart';
import 'package:snug/screens/walkthrough/walkthrough.dart';
import 'package:snug/screens/authenticate/authenticate.dart';
import 'package:snug/screens/settings/verifydelete.dart';
import 'package:snug/services/cognito/CognitoService.dart';
import 'package:snug/themes/colors.dart';
import 'package:snug/themes/constants.dart';
import 'package:snug/themes/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snug/core/logger.dart';
import 'package:toast/toast.dart';
import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrivacyState();
}

class _PrivacyState extends State<PrivacyInfo> with WidgetsBindingObserver {
  SharedPreferences prefs;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // I think this will successfully refresh the user session
    //log.i("APP_STATE: $state");

    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      final prefs = await SharedPreferences.getInstance();
      //log.i('Current user auth token: ${prefs.getString('accessToken')}');
      final _userProvider = Provider.of<UserProvider>(context, listen: false);
      Map<String, dynamic> refreshResponse = await CognitoService.instance
          .refreshAuth(
              _userProvider.getCognitoUser, prefs.getString('refreshToken'));
      if (refreshResponse['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        //log.i('Successfully refreshed user session');
        CognitoUserSession userSession = refreshResponse['data'];
        _userProvider.setUserSession(userSession);
        //log.i('New user auth token: ${prefs.getString('accessToken')}');
      } else {
        //log.e('Failed to refresh user session. Returning to home screen');
        CustomToast.showDialog(
            'Failed to refresh your session. Please sign in again',
            context,
            Toast.BOTTOM);
        await Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Authenticate()));
        });
      }
    }
  }

  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8.0,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Theme.of(context).colorScheme.secondaryVariant,
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final log = getLogger('PrivacyInfo', logProvider.getLogPath);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: new IconButton(
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.secondaryVariant,
          onPressed: () {
            log.i('pushToSignIn');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainPage(
                        fromPrivacyInfo: true,
                      )),
            );
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ])),
          child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * .8,
                    child: PageView(
                      physics: ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .05,
                              right: MediaQuery.of(context).size.width * .05),
                          child: PrivacyCard(
                              title: 'What Snug Collect',
                              body:
                                  'Snug collects and stores your profile information and data submitted about your dates.\n\nThat\'s it.\n\nSnug isn\'t interested in tracking you and believes that your data belongs to you, not us.',
                              icon: Icon(
                                Icons.archive,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryVariant,
                                size: MediaQuery.of(context).size.width * .15,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .05,
                              right: MediaQuery.of(context).size.width * .05),
                          child: PrivacyCard(
                              title: 'How Snug Uses Your Data',
                              body:
                                  'Your information is only used for the functionality of Snug.\n\nBy providing your profile information, you are contributing to a safer dating experience by allowing others to search for you by your phone number.\n\nDon\'t worry, if someone hasn\'t created a profile with Snug, their data won\'t show up when searching.',
                              icon: Icon(
                                Icons.insights,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryVariant,
                                size: MediaQuery.of(context).size.width * .15,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .05,
                              right: MediaQuery.of(context).size.width * .05),
                          child: PrivacyCard(
                            title: 'Delete Your Data',
                            body:
                                'Deleting your account under Account Management on the Settings screen will delete any dates you have created, along with your personal information.\n\nThis will not delete data that others might have entered about you when they add a date.',
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryVariant,
                              size: MediaQuery.of(context).size.width * .15,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
// import 'package:amazon_cognito_identity_dart_2/cognito.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:share/share.dart';
// import 'package:snug/custom_widgets/CustomToast.dart';
// import 'package:snug/custom_widgets/customshowcase.dart';
// import 'package:snug/custom_widgets/privacy_card.dart';
// import 'package:snug/custom_widgets/topheader.dart';
// import 'package:snug/providers/ContactProvider.dart';
// import 'package:snug/providers/DateProvider.dart';
// import 'package:snug/providers/LogProvider.dart';
// import 'package:snug/providers/UserProvider.dart';
// import 'package:snug/screens/navigation/MainPage.dart';
// import 'package:snug/screens/settings/settings.dart';
// import 'package:snug/screens/walkthrough/walkthrough.dart';
// import 'package:snug/screens/authenticate/authenticate.dart';
// import 'package:snug/screens/settings/verifydelete.dart';
// import 'package:snug/services/cognito/CognitoService.dart';
// import 'package:snug/themes/colors.dart';
// import 'package:snug/themes/constants.dart';
// import 'package:snug/themes/themeNotifier.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snug/core/logger.dart';
// import 'package:toast/toast.dart';
// import 'package:emojis/emojis.dart';
// import 'package:emojis/emoji.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:scroll_snap_list/scroll_snap_list.dart';

// class PrivacyInfo extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _PrivacyState();
// }

// class _PrivacyState extends State<PrivacyInfo> with WidgetsBindingObserver {
//   SharedPreferences prefs;

//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     // I think this will successfully refresh the user session
//     //log.i("APP_STATE: $state");

//     if (state == AppLifecycleState.resumed) {
//       // user returned to our app
//       final prefs = await SharedPreferences.getInstance();
//       //log.i('Current user auth token: ${prefs.getString('accessToken')}');
//       final _userProvider = Provider.of<UserProvider>(context, listen: false);
//       Map<String, dynamic> refreshResponse = await CognitoService.instance
//           .refreshAuth(
//               _userProvider.getCognitoUser, prefs.getString('refreshToken'));
//       if (refreshResponse['status'] == true) {
//         final prefs = await SharedPreferences.getInstance();
//         //log.i('Successfully refreshed user session');
//         CognitoUserSession userSession = refreshResponse['data'];
//         _userProvider.setUserSession(userSession);
//         //log.i('New user auth token: ${prefs.getString('accessToken')}');
//       } else {
//         //log.e('Failed to refresh user session. Returning to home screen');
//         CustomToast.showDialog(
//             'Failed to refresh your session. Please sign in again',
//             context,
//             Toast.BOTTOM);
//         await Future.delayed(Duration(seconds: 2), () {
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (context) => Authenticate()));
//         });
//       }
//     }
//   }

//   List<String> titles = [
//     'What We Collect',
//     'How We Use Your Data',
//     'Delete Your Data',
//   ];
//   List<String> bodies = [
//     'We collect and store your profile information and data submitted about your dates.\n\nThat\'s all.\n\nWe aren\'t interested in tracking you and believe that your data belongs to you, not us.',
//     'Your information is only used for the functionality of Snug.\n\nBy providing your profile information, you are contributing to a safer dating experience by allowing others to search for you by your phone number.\n\nDon\'t worry, if someone hasn\'t created a profile with Snug, their data won\'t show up when searching.',
//     'Deleting your account under Account Management on the Settings screen will delete any dates you have created, along with your personal information.\n\nThis will not delete data that others might have entered about you when they add a date.',
//   ];
//   List<IconData> icons = [Icons.archive, Icons.insights, Icons.delete];
//   List<double> middles = [
//     1.375,
//   ];
//   int _focusedIndex = 0;
//   void _onItemFocus(int index) {
//     setState(() {
//       _focusedIndex = index;
//     });
//   }

//   Widget _buildListItem(BuildContext context, int index) {
//     return Row(
//       children: <Widget>[
//         PrivacyCard(
//             title: titles[index],
//             body: bodies[index],
//             icon: Icon(
//               icons[index],
//               color: Theme.of(context).colorScheme.secondaryVariant,
//               size: MediaQuery.of(context).size.width * .15,
//             )),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final logProvider = Provider.of<LogProvider>(context, listen: false);
//     final log = getLogger('PrivacyInfo', logProvider.getLogPath);

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         elevation: 0,
//         leading: new IconButton(
//           icon: Icon(Icons.arrow_back),
//           color: Theme.of(context).colorScheme.secondaryVariant,
//           onPressed: () {
//             log.i('pushToSignIn');
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => MainPage(
//                         fromPrivacyInfo: true,
//                       )),
//             );
//           },
//         ),
//         backgroundColor: Colors.transparent,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//               Theme.of(context).colorScheme.primary,
//               Theme.of(context).colorScheme.secondary
//             ])),
//         child: ScrollSnapList(
//           itemSize: MediaQuery.of(context).size.width * .8,
//           itemBuilder: _buildListItem,
//           itemCount: 3,
//           onItemFocus: _onItemFocus,
//         ),
//       ),
//     );
//   }
// }







// Padding(
//                   padding: EdgeInsets.only(
//                       left: MediaQuery.of(context).size.width * .1),
//                   child: PrivacyCard(
//                       title: 'What We Collect',
//                       body:
//                           'We collect and store your profile information and data submitted about your dates.\n\nThat\'s all.\n\nWe aren\'t interested in tracking you and believe that your data belongs to you, not us.',
//                       icon: Icon(
//                         Icons.archive,
//                         color: Theme.of(context).colorScheme.secondaryVariant,
//                         size: MediaQuery.of(context).size.width * .15,
//                       )),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(
//                       left: MediaQuery.of(context).size.width * .05),
//                   child: PrivacyCard(
//                       title: 'How We Use Your Data',
//                       body:
//                           'Your information is only used for the functionality of Snug.\n\nBy providing your profile information, you are contributing to a safer dating experience by allowing others to search for you by your phone number.\n\nDon\'t worry, if someone hasn\'t created a profile with Snug, their data won\'t show up when searching.',
//                       icon: Icon(
//                         Icons.insights,
//                         color: Theme.of(context).colorScheme.secondaryVariant,
//                         size: MediaQuery.of(context).size.width * .15,
//                       )),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(
//                       left: MediaQuery.of(context).size.width * .05,
//                       right: MediaQuery.of(context).size.width * .1),
//                   child: PrivacyCard(
//                     title: 'Delete Your Data',
//                     body:
//                         'Deleting your account under Account Management on the Settings screen will delete any dates you have created, along with your personal information.\n\nThis will not delete data that others might have entered about you when they add a date.',
//                     icon: Icon(
//                       Icons.delete,
//                       color: Theme.of(context).colorScheme.secondaryVariant,
//                       size: MediaQuery.of(context).size.width * .15,
//                     ),
//                   ),
//                 )