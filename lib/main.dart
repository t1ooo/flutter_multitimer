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
  final _timerRepo = await timerRepo(firstRun.isFirstRun);
  final _settingsRepo = await settingsRepo(firstRun.isFirstRun);
  // ignore: unawaited_futures
  final timersCubit = TimersCubit(_timerRepo, clock)..load();
  // ignore: unawaited_futures
  final settingsCubit = SettingsCubit(_settingsRepo)..load();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: clock),
        RepositoryProvider.value(value: _timerRepo),
        RepositoryProvider.value(value: await notificationService()),
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
