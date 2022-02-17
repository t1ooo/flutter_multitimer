import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/gen/app_localizations.dart';
import 'prototype.dart';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    // required this.settingsController,
  }) : super(key: key);

  // final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // print(Localizations.localeOf(context));
    return MultiBlocProvider(
      providers: [
        // TODO: move to main ?
        BlocProvider<TimersCubit>(
          create: (context) =>
              // TimersCubit(RepositoryProvider.of<TimerRepo>(context))..load(),
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
    // final cubit = context.watch<SettingsCubit>();
    return BlocBuilder<SettingsCubit, SettingsCubitState>(
      // animation: settingsController,
      builder: (BuildContext context, SettingsCubitState state) {
        // print('rebuild material app: ${state.settings?.locale}');
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: state.settings?.locale,
          // localeResolutionCallback:  (Locale? _, Iterable<Locale>__)  {

          // },
          // localeListResolutionCallback: (List<Locale>? _, Iterable<Locale> __ ) {

          // },
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          // themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView();
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
