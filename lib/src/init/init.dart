import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart' show Locale;

import '../l10n/gen/app_localizations.dart';
import '../logging/logging.dart';
import '../settings/logic/settings.dart';
import '../settings/logic/settings_repo.dart';
import '../timer/logic/notification_service.dart';
import '../timer/logic/timer.dart';
import '../timer/logic/timer_repo.dart';

import 'l10n.dart';

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
Future<TimerRepo> createTimerRepo(Locale locale, bool isFirstRun) async {
  final timerRepo = SharedPrefsTimerRepo();
  if (isFirstRun) {
    _initLog.info('populate timer repo');
    final l10n = await loadAppLocalizations(locale);
    for (final timer in initialTimers(l10n)) {
      await timerRepo.create(timer);
    }
  }
  return timerRepo;
}

// ignore: avoid_positional_boolean_parameters
Future<SettingsRepo> createSettingsRepo(Locale locale, bool isFirstRun) async {
  final settingsRepo = SharedPrefsSettingsRepo();
  if (isFirstRun) {
    _initLog.info('init settings repo');
    await settingsRepo.update(Settings(locale: locale));
  }
  return settingsRepo;
}

List<Timer> initialTimers(AppLocalizations l10n) {
  return [
    Timer.initial(
      id: 0,
      name: l10n.timerNameFocus, 
      duration: Duration(minutes: 25),
      now: DateTime.now(),
    ),
    Timer.initial(
      id: 0,
      name: l10n.timerNameBreak,
      duration: Duration(minutes: 5),
      now: DateTime.now(),
    ),
    Timer.initial(
      id: 0,
      name: l10n.timerNameLongBreak,
      duration: Duration(minutes: 15),
      now: DateTime.now(),
    ),
  ];
}
