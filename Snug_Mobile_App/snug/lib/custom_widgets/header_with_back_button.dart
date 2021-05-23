import 'package:flutter/material.dart';
import 'package:snug/screens/create_date/verify_exit.dart';
import 'package:snug/screens/home/home.dart';

class HeaderWithBackButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;

  HeaderWithBackButton({Key key, @required this.child, this.onPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.secondaryVariant),
          onPressed: onPressed,
        ),
        Padding(padding: EdgeInsets.symmetric(), child: child),
        IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.arrow_back, color: Colors.transparent),
          onPressed: () {},
        ),
      ],
    );
  }
}
