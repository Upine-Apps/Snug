import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snug/screens/create_date/verify_exit.dart';
import 'package:snug/screens/home/where.dart';
import 'package:snug/screens/home/who.dart';

class CreateDate extends StatefulWidget {
  @override
  _CreateDateState createState() => _CreateDateState();
}

class _CreateDateState extends State<CreateDate> {
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
        height: 8,
        width: isActive ? 24 : 16,
        decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).dividerColor
                : Theme.of(context).colorScheme.secondaryVariant,
            borderRadius: BorderRadius.all(Radius.circular(12))));
  }

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
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .05),
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          VerifyExit();
                        },
                        icon: Icon(Icons.home),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .1,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * .6,
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
                                child: Expanded(
                              child: Column(children: <Widget>[
                                Center(
                                  child: Text(
                                    'Tell us a little bit about your date!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 26),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .025),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          .05,
                                      left: MediaQuery.of(context).size.width *
                                          .05),
                                  child: Flexible(
                                    child: Container(child: Who()),
                                  ),
                                )
                              ]),
                            )),
                            Center(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  Center(
                                    child: Text(
                                      'Tell us a little bit about your date!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 26),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .025),
                                ])),
                            Center(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  Center(
                                    child: Text(
                                      'Tell us a little bit about your date!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 26),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .025),
                                ])),
                            Center(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  Center(
                                    child: Text(
                                      'Tell us a little bit about your date!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 26),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .025),
                                ])),
                          ],
                        )),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicator(),
                      ),
                    ),
                    _currentPage != _numPages - 1
                        ? Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .1),
                            child: Align(
                                alignment: FractionalOffset.bottomRight,
                                child: TextButton(
                                    onPressed: () {
                                      _pageController.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Next',
                                          style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 22,
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .05),
                                        Icon(Icons.arrow_forward,
                                            color: Theme.of(context).hintColor,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .075)
                                      ],
                                    ))))
                        : Text('')
                  ],
                ),
              )),
        ),
        bottomSheet: _currentPage == _numPages - 1
            ? Container(
                height: MediaQuery.of(context).size.height * .125,
                width: double.infinity,
                color: Theme.of(context).hintColor,
                child: GestureDetector(
                  onTap: () {
                    print('Save date');
                  },
                  child: Center(
                    child: Text(
                      'Save Date!',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            : Text(''));
  }
}
