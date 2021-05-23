import 'package:flutter/material.dart';

class RaisedRoundedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedRoundedGradientButton({
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
        width: width,
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(colors: [
              Theme.of(context).colorScheme.primaryVariant,
              Theme.of(context).colorScheme.secondaryVariant
            ])),
        child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: onPressed, child: Center(child: child))));
  }
}
