import 'package:flutter/material.dart';

class Race extends StatelessWidget {
  final Function onChanged;
  final String value;
  final Function validator;

  Race({Key key, this.onChanged, this.value, this.validator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
            labelText: 'Race',
            alignLabelWithHint: true,
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
              'Black',
            ),
            value: 'B',
          ),
          DropdownMenuItem<String>(
              child: Text(
                'White',
              ),
              value: 'W'),
          DropdownMenuItem<String>(
              child: Text(
                'Hispanic',
              ),
              value: 'H'),
          DropdownMenuItem<String>(
              child: Text(
                'Asian',
              ),
              value: 'A'),
          DropdownMenuItem<String>(
              child: Text(
                'Native American',
              ),
              value: 'I'),
        ],
        onChanged: onChanged,
        hint: Text(
          'Race',
        ),
        value: value);
  }
}
