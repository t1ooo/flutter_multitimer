import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clock/clock.dart';

import 'src/app.dart';
import 'src/init.dart';
import 'src/prototype.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  configureLogger();

  WidgetsFlutterBinding.ensureInitialized();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // final NotificationService notificationService = Platform.isAndroid
  //     ? (AwesomeNotificationService(
  //         key: 'mutlitimer key',
  //         name: 'mutlitimer name',
  //         description: 'mutlitimer desc',
  //         updateChannel: true,
  //       )..init())
  //     : TimerNotificationService();

  final firstRun = await FirstRun.init();

  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: Clock()),
        RepositoryProvider.value(value: await timerRepo(firstRun.isFirstRun)),
        RepositoryProvider.value(
          value: await notificationService(),
        ),
      ],
      child: MyApp(settingsController: settingsController),
    ),
  );
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
