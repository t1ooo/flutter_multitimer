import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final _initLog = Logger('init');
StreamSubscription<LogRecord>? _loggerSub;

void configureLogger() {
  if (!kDebugMode) {
    return;
  }
  if (_loggerSub != null) {
    return;
  }
  Logger.root.level = Level.ALL;
  _loggerSub = Logger.root.onRecord.listen((LogRecord record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message} '
      '${record.error != null ? '${record.error} ' : ''}'
      '${record.stackTrace != null ? '${record.stackTrace}' : ''}',
    );
  });
}
