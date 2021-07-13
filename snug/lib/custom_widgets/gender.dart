import 'package:flutter/material.dart';

class Gender extends StatelessWidget {
  final Function onChanged;
  final String value;
  final Function validator;

  Gender({Key key, this.onChanged, this.value, this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16),
        decoration: InputDecoration(
            labelText: 'Sex',
            alignLabelWithHint: true,
            errorStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondaryVariant),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondaryVariant))),
        validator: validator,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.secondaryVariant,
        ),
        isDense: false,
        isExpanded: false,
        items: [
          DropdownMenuItem<String>(
            child: Text(
              'Female',
            ),
            value: 'F',
          ),
          DropdownMenuItem<String>(
              child: Text(
                'Male',
              ),
              value: 'M'),
        ],
        onChanged: onChanged,
        hint: Text(
          'Sex',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        value: value);
  }
}
