import 'package:flutter/material.dart';

class Eye extends StatelessWidget {
  final Function onChanged;
  final String value;
  final Function validator;

  Eye({Key key, this.onChanged, this.value, this.validator}) : super(key: key);
  @override
  String _eye;
  Widget build(BuildContext context) {
    return Container(
        child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
                labelText: 'Eye Color',
                alignLabelWithHint: true,
                errorStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryVariant),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Theme.of(context).colorScheme.secondaryVariant))),
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
                value: 'BLK',
              ),
              DropdownMenuItem<String>(
                  child: Text(
                    'Blue',
                  ),
                  value: 'BLU'),
              DropdownMenuItem<String>(
                  child: Text(
                    'Green',
                  ),
                  value: 'GRN'),
              DropdownMenuItem<String>(
                  child: Text(
                    'Brown',
                  ),
                  value: 'BRO'),
              DropdownMenuItem<String>(
                  child: Text(
                    'Pink',
                  ),
                  value: 'PNK'),
              DropdownMenuItem<String>(
                  child: Text(
                    'Gray',
                  ),
                  value: 'GRY'),
              DropdownMenuItem<String>(
                  child: Text(
                    'Hazel',
                  ),
                  value: 'HZL'),
              DropdownMenuItem<String>(
                  child: Text(
                    'Other',
                  ),
                  value: 'OTH'),
            ],
            onChanged: onChanged,
            hint: Text('Eye Color',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black54)),
            value: value));
  }
}
