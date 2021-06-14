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
        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16),
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
            ),
            value: 'BLD',
          ),
          DropdownMenuItem<String>(
              child: Text(
                'Brown',
              ),
              value: 'BRN'),
          DropdownMenuItem<String>(
              child: Text(
                'Black',
              ),
              value: 'BLK'),
          DropdownMenuItem<String>(
              child: Text(
                'Blonde',
              ),
              value: 'BLN'),
          DropdownMenuItem<String>(
              child: Text(
                'Blue',
              ),
              value: 'BLU'),
          DropdownMenuItem<String>(
              child: Text(
                'Gray',
              ),
              value: 'GRY'),
          DropdownMenuItem<String>(
              child: Text(
                'Green',
              ),
              value: 'GRN'),
          DropdownMenuItem<String>(
              child: Text(
                'Orange',
              ),
              value: 'ONG'),
          DropdownMenuItem<String>(
              child: Text(
                'Pink',
              ),
              value: 'PNK'),
          DropdownMenuItem<String>(
              child: Text(
                'Red',
              ),
              value: 'RED'),
          DropdownMenuItem<String>(
              child: Text(
                'White',
              ),
              value: 'WHI'),
          DropdownMenuItem<String>(
              child: Text(
                'Other',
              ),
              value: 'OTH'),
        ],
        onChanged: onChanged,
        hint: Text(
          'Hair Color',
        ),
        value: value);
  }
}
