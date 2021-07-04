import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CustomToast {
  static showDialog(String msg, context, var location) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG,
        gravity: location,
        textColor: Theme.of(context).colorScheme.secondaryVariant,
        backgroundColor: Theme.of(context).dividerColor);
  }
}
