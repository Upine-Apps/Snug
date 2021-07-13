import 'dart:io';
import 'package:logger/src/outputs/file_output.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

Future<Logger> getLogger(String className) async {
  return Logger(
      printer: SimpleLogPrinter(className),
      output: FileOutput(file: File("$path/log.txt")));
}

class SimpleLogPrinter extends LogPrinter {
  final String className;
  SimpleLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    AnsiColor color = PrettyPrinter.levelColors[event.level];
    String emoji = PrettyPrinter.levelEmojis[event.level];
    return [color('$emoji [$className]: ${event.message}')];
  }
}
