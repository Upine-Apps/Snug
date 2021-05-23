import 'package:flutter/material.dart';

class RaisedCircularGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedCircularGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: height,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              Theme.of(context).colorScheme.primaryVariant,
              Theme.of(context).colorScheme.secondaryVariant
            ])),
        child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: onPressed, child: Center(child: child))));
  }
}
