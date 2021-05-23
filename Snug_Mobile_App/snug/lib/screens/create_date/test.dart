import 'package:flutter/material.dart';

void main() => runApp(MyTextFieldApp());

class MyTextFieldApp extends StatelessWidget {
  ValueNotifier<bool> _textHasErrorNotifier = ValueNotifier(false);

  _updateErrorText(String text) {
    var result = (text == null || text == "");
    _textHasErrorNotifier.value = result;
  }

  Widget _getPrefixText() {
    return Icon(Icons.ac_unit);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: _textHasErrorNotifier,
                    child: _getPrefixText(),
                    builder:
                        (BuildContext context, bool hasError, Widget child) {
                      return TextField(
                        onChanged: _updateErrorText,
                        decoration: InputDecoration(
                          prefix: child,
                          fillColor: Colors.grey[100],
                          filled: true,
                          errorText:
                              hasError ? 'Invalid value entered...' : null,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 0.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 0.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 0.0),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      );
                    },
                  ),
                ))));
  }
}
