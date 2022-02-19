import 'dart:async';
import 'dart:io';

import '../logging/logging.dart';
import '../settings/logic/settings_repo.dart';
import '../timer/logic/notification_service.dart';
import '../timer/logic/timer.dart';
import '../timer/logic/timer_repo.dart';

final _initLog = Logger('init');
StreamSubscription<LogRecord>? _loggerSub;

// ignore: avoid_positional_boolean_parameters
void configureLogger(bool debugMode) {
  if (!debugMode) {
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

Future<NotificationService> createNotificationService() async {
  if (Platform.isAndroid) {
    return AwesomeNotificationService.create(
      key: 'mutlitimer key',
      name: 'mutlitimer name',
      description: 'mutlitimer desc',
      // l10n: NotificationLocalizations(),
      // updateChannel: true,
    );
  }
  return SimpleNotificationService();
}

// ignore: avoid_positional_boolean_parameters
Future<TimerRepo> createTimerRepo(bool isFirstRun) async {
  final timerRepo = SharedPrefsTimerRepo();
  if (isFirstRun) {
    _initLog.info('populate timer repo');
    for (final timer in initialTimers()) {
      await timerRepo.create(timer);
    }
  }
  return timerRepo;
}

// ignore: avoid_positional_boolean_parameters
Future<SettingsRepo> createSettingsRepo(bool isFirstRun) async {
  final settingsRepo = SharedPrefsSettingsRepo();
  return settingsRepo;
}

List<Timer> initialTimers() {
  return [
    Timer.initial(
      id: 0,
      name: 'focus',
      duration: Duration(minutes: 25),
      now: DateTime.now(),
    ),
    Timer.initial(
      id: 0,
      name: 'break',
      duration: Duration(minutes: 5),
      now: DateTime.now(),
    ),
    Timer.initial(
      id: 0,
      name: 'long break',
      duration: Duration(minutes: 15),
      now: DateTime.now(),
    ),
  ];
}
