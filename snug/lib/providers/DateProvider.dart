import 'package:flutter/material.dart';

import '../models/Date.dart';
import '../models/User.dart';

class DateProvider extends ChangeNotifier {
  List<Date> _dates = new List<Date>();

  List<Date> get getCurrentDates {
    print('in provider getDates');
    print(_dates.length);
    return _dates;
  }

  setRecentDate(Date updatedDate) {
    _dates.last = updatedDate;
    notifyListeners();
  }

  //adding date to provider. Only specify `isArchived` if adding date to archived dates
  // TAKE OUT USER 2 AND GET THE ONE FROM THE REMOTE DATABASE FOR REPORTED USER TABLE
  //

  addDate(Date _date) async {
    _dates.add(_date);
    notifyListeners();
  }

  Date get getRecentDate {
    return _dates.last;
  }

  void removeDate(int index) {
    _dates.removeAt(index);
    notifyListeners();
  }
}
