import 'package:flutter/material.dart';

class FiftyStates extends StatelessWidget {
  final Function onChanged;
  final String value;
  final Function validator;

  FiftyStates({Key key, this.onChanged, this.value, this.validator})
      : super(key: key);

  @override
  String _state;
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'State',
            alignLabelWithHint: true,
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
            child: Text('Alabama'),
            value: 'AL',
          ),
          DropdownMenuItem<String>(child: Text('Alaska'), value: 'AK'),
          DropdownMenuItem<String>(child: Text('Arizona '), value: 'AZ'),
          DropdownMenuItem<String>(child: Text('Arkansas '), value: 'AR'),
          DropdownMenuItem<String>(child: Text('California '), value: 'CA'),
          DropdownMenuItem<String>(child: Text('Colorado '), value: 'CO'),
          DropdownMenuItem<String>(child: Text('Connecticut '), value: 'CT'),
          DropdownMenuItem<String>(child: Text('Delaware  '), value: 'DE'),
          DropdownMenuItem<String>(child: Text('Florida  '), value: 'FL'),
          DropdownMenuItem<String>(child: Text('Georgia  '), value: 'GA'),
          DropdownMenuItem<String>(child: Text('Hawaii  '), value: 'HI'),
          DropdownMenuItem<String>(child: Text('Idaho  '), value: 'ID'),
          DropdownMenuItem<String>(child: Text('Illinois  '), value: 'IL'),
          DropdownMenuItem<String>(child: Text('Indiana'), value: 'IN'),
          DropdownMenuItem<String>(child: Text('Iowa'), value: 'IA'),
          DropdownMenuItem<String>(child: Text('Kansas'), value: 'KS'),
          DropdownMenuItem<String>(child: Text('Kentucky  '), value: 'KY'),
          DropdownMenuItem<String>(child: Text('Louisiana  '), value: 'LA'),
          DropdownMenuItem<String>(child: Text('Maine  '), value: 'ME'),
          DropdownMenuItem<String>(child: Text('Maryland  '), value: 'MD'),
          DropdownMenuItem<String>(child: Text('Massachusetts  '), value: 'MA'),
          DropdownMenuItem<String>(child: Text('Michigan  '), value: 'MI'),
          DropdownMenuItem<String>(child: Text('Minnesota  '), value: 'MN'),
          DropdownMenuItem<String>(child: Text('Mississippi  '), value: 'MS'),
          DropdownMenuItem<String>(child: Text('Missouri  '), value: 'MO'),
          DropdownMenuItem<String>(child: Text('Montana  '), value: 'MT'),
          DropdownMenuItem<String>(child: Text('Nebraska  '), value: 'NE'),
          DropdownMenuItem<String>(child: Text('Nevada   '), value: 'NV'),
          DropdownMenuItem<String>(child: Text('New Hampshire  '), value: 'NH'),
          DropdownMenuItem<String>(child: Text('New Jersey  '), value: 'NJ'),
          DropdownMenuItem<String>(child: Text('New Mexico'), value: 'NM'),
          DropdownMenuItem<String>(child: Text('New York'), value: 'NY'),
          DropdownMenuItem<String>(
              child: Text('North Carolina  '), value: 'NC'),
          DropdownMenuItem<String>(child: Text('North Dakota'), value: 'ND'),
          DropdownMenuItem<String>(child: Text('Ohio'), value: 'OH'),
          DropdownMenuItem<String>(child: Text('Oklahoma'), value: 'OK'),
          DropdownMenuItem<String>(child: Text('Oregon'), value: 'OR'),
          DropdownMenuItem<String>(child: Text('Pennsylvania '), value: 'PA'),
          DropdownMenuItem<String>(child: Text('Rhode Island'), value: 'RI'),
          DropdownMenuItem<String>(child: Text('South Carolina'), value: 'SC'),
          DropdownMenuItem<String>(child: Text('South Dakota'), value: 'SD'),
          DropdownMenuItem<String>(child: Text('Tennessee  '), value: 'TN'),
          DropdownMenuItem<String>(child: Text('Texas  '), value: 'TX'),
          DropdownMenuItem<String>(child: Text('Utah   '), value: 'UT'),
          DropdownMenuItem<String>(child: Text('Vermont   '), value: 'VT'),
          DropdownMenuItem<String>(child: Text('Virginia   '), value: 'VA'),
          DropdownMenuItem<String>(child: Text('Washington   '), value: 'WA'),
          DropdownMenuItem<String>(
              child: Text('West Virginia   '), value: 'WV'),
          DropdownMenuItem<String>(child: Text('Wisconsin   '), value: 'WI'),
          DropdownMenuItem<String>(child: Text('Wyoming   '), value: 'WY'),
        ],
        onChanged: onChanged,
        hint: Text('State',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black54)),
        value: value);
  }
}
