import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snug/screens/navigation/MainPage.dart';
import 'package:snug/screens/sync/sync.dart';

class Walkthrough extends StatefulWidget {
  @override
  _WalkthroughState createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  final int _numPages = 4;
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
          color: isActive ? Colors.white : Color(0xFF7B51D3),
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(0),
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MainPage()),
                          );
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .7,
                      child: PageView(
                        physics: ClampingScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: <Widget>[
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                    child: Image(
                                  image: AssetImage('assets/image/logo1.png'),
                                  height:
                                      MediaQuery.of(context).size.height * .3,
                                  width:
                                      MediaQuery.of(context).size.height * .3,
                                )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'Thanks For Choosing Snug!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'Before starting let us show you some of our unique features! Our goal is to make sure that you can date freely!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                  child: ClipOval(
                                      child: Material(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant,
                                          child: InkWell(
                                            splashColor: Theme.of(context)
                                                .colorScheme
                                                .primaryVariant,
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .3,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .3,
                                              child: Icon(
                                                Icons.favorite,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {},
                                          ))),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'Create A Date!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'The above button is displayed on the home screen. Use it to create a date! Once the date is finished, we will check in with you via text message if you haven\'t marked yourself safe. If we don\'t hear back after 20 minutes, we\'ll let your contact know.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                  child: ClipOval(
                                      child: Material(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant,
                                          child: InkWell(
                                            splashColor: Theme.of(context)
                                                .colorScheme
                                                .primaryVariant,
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .3,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .3,
                                              child: Icon(
                                                Icons.person_add,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {},
                                          ))),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'Create A Contact!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'This button is displayed on the contact screen. Use it to create your contacts! These are the people that got your back if anything happens.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                  child: ClipOval(
                                      child: Material(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryVariant,
                                          child: InkWell(
                                            splashColor: Theme.of(context)
                                                .colorScheme
                                                .primaryVariant,
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .35,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .35,
                                              child: Icon(
                                                Icons.edit,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {},
                                          ))),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'Edit Your Profile!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .025,
                                ),
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .9,
                                    child: Text(
                                      'Changed your hair color? Look for this button on the profile screen to edit your profile!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              ],
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
                    _currentPage != _numPages - 1
                        ? Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .075),
                            child: Align(
                              alignment: FractionalOffset.bottomRight,
                              child: FlatButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('Next',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22.0,
                                        )),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .05,
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.width *
                                          .075,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Text(''),
                  ],
                )),
          ),
        ),
        bottomSheet: _currentPage == _numPages - 1
            ? Container(
                height: MediaQuery.of(context).size.height * .125,
                width: double.infinity,
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Get Started!',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            : Text(''));
  }
}
