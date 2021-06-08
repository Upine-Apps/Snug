import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SyncScreen()),
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
                      height: 600,
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
                              padding: EdgeInsets.all(40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Center(
                                      child: Image(
                                    image: AssetImage('assets/image/logo1.png'),
                                    height: 300,
                                    width: 300,
                                  )),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    'Thanks For Choosing Snug!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                        height: 1.5),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Before starting let us show you some of our unique features! Our goal is to make sure that you can date freely!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      height: 1.2,
                                    ),
                                  )
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.all(40),
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
                                                width: 300,
                                                height: 300,
                                                child: Icon(
                                                  Icons.favorite,
                                                  size: 150,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onTap: () {},
                                            ))),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    'Create A Date!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.0,
                                        height: 1.5),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'The above button is displayed on the home screen. Use it to create a date! Once the date is created we will make sure that you are safe throughout. If something happens, we\'ll let your contact know. ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      height: 1.2,
                                    ),
                                  )
                                ],
                              )),
                          Padding(
                            padding: EdgeInsets.all(40),
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
                                              width: 300,
                                              height: 300,
                                              child: Icon(
                                                Icons.person_add,
                                                size: 150,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {},
                                          ))),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  'Create A Contact!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.0,
                                      height: 1.5),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'The above button is displayed on the contact screen. Use it to create your contacts! These are the people that got your back if anything happens.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    height: 1.2,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(40),
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
                                              width: 300,
                                              height: 300,
                                              child: Icon(
                                                Icons.edit,
                                                size: 150,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {},
                                          ))),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  'Edit Your Profile!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.0,
                                      height: 1.5),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'The above button is displayed on the profile screen. Use it to edit your profile!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    height: 1.2,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                    _currentPage != _numPages - 1
                        ? Expanded(
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
                                      width: 10.0,
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 30,
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
                height: 100,
                width: double.infinity,
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SyncScreen()),
                    );
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Get Started!',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            : Text(''));
  }
}
