import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowCase extends StatelessWidget {
  final Widget child;
  final String description;
  final GlobalKey globalKey;

  CustomShowCase(
      {@required this.child,
      @required this.description,
      @required this.globalKey});

  @override
  Widget build(BuildContext context) => Showcase(
        key: globalKey,
        showcaseBackgroundColor: Theme.of(context).colorScheme.secondaryVariant,
        description: description,
        descTextStyle:
            TextStyle(color: Theme.of(context).dividerColor, fontSize: 16),
        child: child,
        overlayOpacity: 0.5,
        shapeBorder: CircleBorder(),
      );
}
