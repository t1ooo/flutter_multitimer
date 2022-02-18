import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/init/first_run.dart';
import 'src/init/init.dart';
import 'src/settings/logic/settings_cubit.dart';
import 'src/timer/logic/timers_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureLogger(kDebugMode);

  final firstRun = await FirstRun.create();
  final clock = Clock();
  final timerRepo = await createTimerRepo(firstRun.isFirstRun);
  final settingsRepo = await createSettingsRepo(firstRun.isFirstRun);
  // ignore: unawaited_futures
  final timersCubit = TimersCubit(timerRepo, clock)..load();
  // ignore: unawaited_futures
  final settingsCubit = SettingsCubit(settingsRepo)..load();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: clock),
        RepositoryProvider.value(value: timerRepo),
        RepositoryProvider.value(value: await createNotificationService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: timersCubit),
          BlocProvider.value(value: settingsCubit),
        ],
        child: MyApp(),
      ),
    ),
  );
}
