import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CustomToast {
  static showDialog(String msg, context) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Theme.of(context).dividerColor,
        backgroundColor: Theme.of(context).colorScheme.secondaryVariant);
  }
}
