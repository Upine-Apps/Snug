import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Month extends StatefulWidget {
  _MonthState createState() => _MonthState();
}

class _MonthState extends State<Month> {
  String _month;
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          isDense: false,
          isExpanded: false,
          items: [
            DropdownMenuItem<String>(child: Text('January'), value: '01'),
            DropdownMenuItem<String>(child: Text('February'), value: '02'),
            DropdownMenuItem<String>(child: Text('March'), value: '03'),
            DropdownMenuItem<String>(child: Text('April'), value: '04'),
            DropdownMenuItem<String>(child: Text('May'), value: '05'),
            DropdownMenuItem<String>(child: Text('June'), value: '06'),
            DropdownMenuItem<String>(child: Text('July'), value: '07'),
            DropdownMenuItem<String>(child: Text('August'), value: '08'),
            DropdownMenuItem<String>(child: Text('September'), value: '09'),
            DropdownMenuItem<String>(child: Text('October'), value: '10'),
            DropdownMenuItem<String>(child: Text('Novemeber'), value: '11'),
            DropdownMenuItem<String>(child: Text('December'), value: '12'),
          ],
          onChanged: (String val) {
            setState(() async {
              _month = val;
              SharedPreferences profile = await SharedPreferences.getInstance();
              profile.setString('_month', _month);
            });
          },
          hint: Text('Month', style: TextStyle(color: Colors.white)),
          value: _month),
    );
  }
}
