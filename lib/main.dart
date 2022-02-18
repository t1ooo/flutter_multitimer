import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/init/first_run.dart';
import 'src/init/init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureLogger(kDebugMode);

  final firstRun = await FirstRun.create();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: Clock()),
        RepositoryProvider.value(
          value: await settingsRepo(firstRun.isFirstRun),
        ),
        RepositoryProvider.value(value: await timerRepo(firstRun.isFirstRun)),
        RepositoryProvider.value(
          value: await notificationService(),
        ),
      ],
      child: MyApp(),
    ),
  );
}
