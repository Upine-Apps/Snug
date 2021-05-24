import 'package:flutter/cupertino.dart';
import 'package:snug/core/logger.dart';
import 'package:snug/providers/ContactProvider.dart';
import 'package:provider/provider.dart';

Future syncContact(Map trustedContacts, BuildContext context) async {
  final log = getLogger('syncContacts');
  log.i(
      'syncContact | trustedContacts: $trustedContacts, BuildContext: $context');
  final contactProvider = Provider.of<ContactProvider>(context, listen: false);
  try {
    trustedContacts.forEach((key, value) {
      log.d('Key: $key | Value: $value');
      contactProvider.addContact(value['name'], value['phone_number']);
    });
    return {'status': true};
  } catch (e) {
    log.e('Caught exception $e');
    return {'status': false};
  }
}
