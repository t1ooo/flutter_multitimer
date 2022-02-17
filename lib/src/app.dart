import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/gen/app_localizations.dart';
import 'prototype.dart';
import 'settings_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(Localizations.localeOf(context));
    return MultiBlocProvider(
      providers: [
        // TODO: move to main ?
        BlocProvider<TimersCubit>(
          create: (context) =>
              TimersCubit(context.read<TimerRepo>(), context.read<Clock>())
                ..load(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) =>
              SettingsCubit(context.read<SettingsRepo>())..load(),
        ),
      ],
      child: builder(context),
    );
  }

  Widget builder(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsCubitState>(
      builder: (BuildContext context, SettingsCubitState state) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: state.settings?.locale,
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          home: HomeView(),
        );
      },
    );
  }
}
