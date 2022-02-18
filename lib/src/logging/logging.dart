import 'package:logging/logging.dart';
export 'package:logging/logging.dart' show Logger, Level, LogRecord;

extension LoggerExt on Logger {
  void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    severe(message, error, stackTrace);
  }
}
