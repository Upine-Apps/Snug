import 'package:flutter/material.dart';

class Feet extends StatelessWidget {
  final Function onChanged;
  final String value;
  final Function validator;

  Feet({Key key, this.onChanged, this.value, this.validator}) : super(key: key);
  @override
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
        ],
        onChanged: onChanged,
        hint: Text('Feet',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black54,
            )),
        value: value);
  }
}
