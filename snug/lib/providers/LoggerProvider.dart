import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snug/services/remote_db_service.dart';
import '../models/Contact.dart';

class LogProvider extends ChangeNotifier {
  Directory _path;
  Directory get getLogPath {
    return _path;
  }

  void setLogPath(Directory logPath) {
    _path = logPath;
  }
}
