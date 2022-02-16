import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_pomodoro_prototype_skeleton_bloc/src/prototype.dart';
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



Future<NotificationService> notificationService() async {
  if (Platform.isAndroid) {
    final ns = AwesomeNotificationService(
      key: 'mutlitimer key',
      name: 'mutlitimer name',
      description: 'mutlitimer desc',
      l10n: NotificationLocalizations(),
      updateChannel: true,
    );
    await ns.init();
    return ns;
  }
  return TimerNotificationService();
}

Future<TimerRepo> timerRepo(bool isFirstRun) async {
  final timerRepo = InMemoryTimerRepo();
  if (isFirstRun) {
    for (final timer in initialTimers()) {
      await timerRepo.create(timer);
    }
  }
  return timerRepo;
}

List<Timer> initialTimers() {
  return [
    Timer(
      id: 0,
      name: 'stop',
      duration: Duration(seconds: 60 * 60 * 2),
      countdown: Duration(seconds: 60 * 60 * 2),
      status: TimerStatus.stop,
      lastUpdate: DateTime.now(),
      startedAt: DateTime.now(),
    ),
    Timer(
      id: 1,
      name: 'stop',
      duration: Duration(seconds: 125),
      countdown: Duration(seconds: 125),
      status: TimerStatus.stop,
      lastUpdate: DateTime.now(),
      startedAt: DateTime.now(),
    ),
    Timer(
      id: 2,
      name: 'pause',
      duration: Duration(seconds: 5),
      countdown: Duration(seconds: 5),
      status: TimerStatus.pause,
      lastUpdate: DateTime.now(),
      startedAt: DateTime.now(),
    ),
    Timer(
      id: 3,
      name: 'start',
      duration: Duration(seconds: 10),
      countdown: Duration(seconds: 10),
      status: TimerStatus.start,
      lastUpdate: DateTime.now(),
      startedAt: DateTime.now(),
    ),
  ];
}
