import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final Widget child;

  const Header({
    Key key,
    @required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new Container(
        // decoration: BoxDecoration(color: Colors.white),
        child: new Center(child: child));
  }
}
