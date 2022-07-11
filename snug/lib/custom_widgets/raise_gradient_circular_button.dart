import 'package:flutter/material.dart';

class RaisedCircularGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;
  final double elevation;

  const RaisedCircularGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      GestureDetector(
        onTap: onPressed,
        child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primaryVariant,
                Theme.of(context).colorScheme.secondaryVariant
              ]),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(1, 5), // changes position of shadow
                ),
              ],
            ),
            child: Center(child: child)),
      ),
    ]);
  }
}
