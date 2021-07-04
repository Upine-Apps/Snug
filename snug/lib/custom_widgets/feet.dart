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
            labelText: 'Feet',
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
                '2',
              ),
              value: '2'),
          DropdownMenuItem<String>(
              child: Text(
                '3',
              ),
              value: '3'),
          DropdownMenuItem<String>(
              child: Text(
                '4',
              ),
              value: '4'),
          DropdownMenuItem<String>(
              child: Text(
                '5',
              ),
              value: '5'),
          DropdownMenuItem<String>(
              child: Text(
                '6',
              ),
              value: '6'),
          DropdownMenuItem<String>(
              child: Text(
                '7',
              ),
              value: '7'),
          DropdownMenuItem<String>(
              child: Text(
                '8',
              ),
              value: '8'),
        ],
        onChanged: onChanged,
        hint: Text('Feet'),
        value: value);
  }
}
