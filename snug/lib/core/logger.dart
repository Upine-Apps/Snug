import 'dart:io';
import 'package:logger/src/outputs/file_output.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

Logger getLogger(String className, Directory logPath) {
  print(logPath.path);
  return Logger(
      printer: FileLogPrinter(className),
      output: FileOutput(file: File("${logPath.path}/log.txt")));
}

Logger getConsoleLogger(String className) {
  return Logger(
    printer: SimpleLogPrinter(className),
  );
}

class FileLogPrinter extends LogPrinter {
  final String className;
  FileLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    return [
      '${event.level} [$className]: ${event.message} ${DateTime.now()} \n'
    ];
  }
}

//THIS FOR THE CONSOLE
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
