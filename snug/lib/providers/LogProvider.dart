import 'dart:io';

import 'package:flutter/material.dart';

class LogProvider extends ChangeNotifier {
  Directory _path;
  Directory get getLogPath {
    print('RETURNING LOG PATH');
    print(_path);
    print('DONE RETURNING LOG PATH');
    return _path;
  }

  void setLogPath(Directory logPath) {
    _path = logPath;
    print('SETTING LOG PATH');
    print(logPath);
    print('DONE SETTING LOG PATH');
  }
}
