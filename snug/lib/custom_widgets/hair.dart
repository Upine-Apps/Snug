import 'package:flutter/material.dart';

class Hair extends StatelessWidget {
  final Function onChanged;
  final String value;
  final Function validator;

  Hair({Key key, this.onChanged, this.value, this.validator}) : super(key: key);

  @override
  String _hair;
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
              'Bald',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black54
                    : Colors.white,
              ),
            ),
            value: 'BLD',
          ),
          DropdownMenuItem<String>(
              child: Text(
                'Brown',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'BRN'),
          DropdownMenuItem<String>(
              child: Text(
                'Black',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'BLK'),
          DropdownMenuItem<String>(
              child: Text(
                'Blonde',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'BLN'),
          DropdownMenuItem<String>(
              child: Text(
                'Blue',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'BLU'),
          DropdownMenuItem<String>(
              child: Text(
                'Gray',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'GRY'),
          DropdownMenuItem<String>(
              child: Text(
                'Green',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'GRN'),
          DropdownMenuItem<String>(
              child: Text(
                'Orange',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'ONG'),
          DropdownMenuItem<String>(
              child: Text(
                'Pink',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'PNK'),
          DropdownMenuItem<String>(
              child: Text(
                'Red',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'RED'),
          DropdownMenuItem<String>(
              child: Text(
                'White',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'WHI'),
          DropdownMenuItem<String>(
              child: Text(
                'Other',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
              value: 'OTH'),
        ],
        onChanged: onChanged,
        hint: Text('Hair Color',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black54)),
        value: value);
  }
}
