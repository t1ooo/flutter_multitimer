import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/init.dart';
import 'src/prototype.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureLogger();

  final firstRun = await FirstRun.init();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: Clock()),
        RepositoryProvider.value(
            value: await settingsRepo(firstRun.isFirstRun)),
        RepositoryProvider.value(value: await timerRepo(firstRun.isFirstRun)),
        RepositoryProvider.value(
          value: await notificationService(),
        ),
      ],
      child: MyApp(),
    ),
  );
}
