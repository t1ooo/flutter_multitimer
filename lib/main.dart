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
  firstRun.reset();

  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: Clock()),
        RepositoryProvider.value(value: await settingsRepo(firstRun.isFirstRun)),
        RepositoryProvider.value(value: await timerRepo(firstRun.isFirstRun)),
        RepositoryProvider.value(
          value: await notificationService(),
        ),
      ],
      child: MyApp(),
    ),
  );
}
