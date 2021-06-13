import 'package:flutter/material.dart';

class Inch extends StatelessWidget {
  final Function onChanged;
  final String value;
  final Function validator;

  Inch({Key key, this.onChanged, this.value, this.validator}) : super(key: key);
  @override
  String _in;
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
            errorStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondaryVariant),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondaryVariant))),
        validator: validator,
        style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black54,
            fontSize: 16),
        icon: Icon(
          // Add this
          Icons.arrow_drop_down, // Add this
          color: Theme.of(context).colorScheme.secondaryVariant,
        ),
        isDense: false,
        isExpanded: false,
        items: [
          DropdownMenuItem<String>(
              child: Text(
                '0',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '0'),
          DropdownMenuItem<String>(
              child: Text(
                '1',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '1'),
          DropdownMenuItem<String>(
              child: Text(
                '2',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '2'),
          DropdownMenuItem<String>(
              child: Text(
                '3',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '3'),
          DropdownMenuItem<String>(
              child: Text(
                '4',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '4'),
          DropdownMenuItem<String>(
              child: Text(
                '5',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '5'),
          DropdownMenuItem<String>(
              child: Text(
                '6',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '6'),
          DropdownMenuItem<String>(
              child: Text(
                '7',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '7'),
          DropdownMenuItem<String>(
              child: Text(
                '8',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '8'),
          DropdownMenuItem<String>(
              child: Text(
                '9',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '9'),
          DropdownMenuItem<String>(
              child: Text(
                '10',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '10'),
          DropdownMenuItem<String>(
              child: Text(
                '11',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: '11'),
        ],
        onChanged: onChanged,
        hint: Text(
          'Inch',
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black54),
        ),
        value: value);
  }
}
