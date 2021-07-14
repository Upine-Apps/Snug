import 'dart:io';

import 'package:flutter/material.dart';

class LogProvider extends ChangeNotifier {
  String _path;

  String get getLogPath {
    print('RETURNING LOG PATH');
    print(_path);
    print('DONE RETURNING LOG PATH');
    return _path;
  }

  void setLogPath(String logPath) {
    _path = logPath;
    print('SETTING LOG PATH');
    print(logPath);
    print('DONE SETTING LOG PATH');
  }
}
