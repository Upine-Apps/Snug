import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Day extends StatefulWidget {
  _DayState createState() => _DayState();
}

class _DayState extends State<Day> {
  String _day;
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          isDense: false,
          isExpanded: false,
          items: [
            DropdownMenuItem<String>(child: Text('01'), value: '01'),
            DropdownMenuItem<String>(child: Text('02'), value: '02'),
            DropdownMenuItem<String>(child: Text('03'), value: '03'),
            DropdownMenuItem<String>(child: Text('04'), value: '04'),
            DropdownMenuItem<String>(child: Text('05'), value: '05'),
            DropdownMenuItem<String>(child: Text('06'), value: '06'),
            DropdownMenuItem<String>(child: Text('07'), value: '07'),
            DropdownMenuItem<String>(child: Text('08'), value: '08'),
            DropdownMenuItem<String>(child: Text('09'), value: '09'),
            DropdownMenuItem<String>(child: Text('10'), value: '10'),
            DropdownMenuItem<String>(child: Text('11'), value: '11'),
            DropdownMenuItem<String>(child: Text('12'), value: '12'),
            DropdownMenuItem<String>(child: Text('13'), value: '13'),
            DropdownMenuItem<String>(child: Text('14'), value: '14'),
            DropdownMenuItem<String>(child: Text('15'), value: '15'),
            DropdownMenuItem<String>(child: Text('16'), value: '16'),
            DropdownMenuItem<String>(child: Text('17'), value: '17'),
            DropdownMenuItem<String>(child: Text('18'), value: '18'),
            DropdownMenuItem<String>(child: Text('19'), value: '19'),
            DropdownMenuItem<String>(child: Text('20'), value: '20'),
            DropdownMenuItem<String>(child: Text('21'), value: '21'),
            DropdownMenuItem<String>(child: Text('22'), value: '22'),
            DropdownMenuItem<String>(child: Text('23'), value: '23'),
            DropdownMenuItem<String>(child: Text('24'), value: '24'),
            DropdownMenuItem<String>(child: Text('25'), value: '25'),
            DropdownMenuItem<String>(child: Text('26'), value: '26'),
            DropdownMenuItem<String>(child: Text('27'), value: '27'),
            DropdownMenuItem<String>(child: Text('28'), value: '28'),
            DropdownMenuItem<String>(child: Text('29'), value: '29'),
            DropdownMenuItem<String>(child: Text('30'), value: '30'),
            DropdownMenuItem<String>(child: Text('31'), value: '31'),
          ],
          onChanged: (String val) {
            setState(() async {
              _day = val;
              SharedPreferences profile = await SharedPreferences.getInstance();
              profile.setString('_day', _day);
            });
          },
          hint: Text('Day', style: TextStyle(color: Colors.white)),
          value: _day),
    );
  }
}
