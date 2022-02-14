import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_pomodoro_prototype_skeleton_bloc/src/prototype.dart';

import 'l10n/gen/app_localizations.dart';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Clock>(create: (context) => Clock()),
        RepositoryProvider<TimerRepo>(create: (context) => TimerRepo()),
        RepositoryProvider<NotificationService>(
          create: (context) => Platform.isAndroid
              ? AwesomeNotificationService(
                  key: 'mutlitimer key',
                  name: 'mutlitimer name',
                  description: 'mutlitimer desc',
                  updateChannel: true,
                )
              : TimerNotificationService(),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            // TimersCubit(RepositoryProvider.of<TimerRepo>(context))..load(),
            TimersCubit(context.read<TimerRepo>(), context.read<Clock>())..load(),
        child: builder(context),
      ),
    );
  }

  Widget builder(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case SampleItemListView.routeName:
                  default:
                    return HomeView();
                }
              },
            );
          },
        );
      },
    );
  }
}
