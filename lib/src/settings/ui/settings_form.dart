import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../util/snackbar.dart';

import '../logic/settings_cubit.dart';

// SettingsCubit watchSettingsCubit(BuildContext context) => context.watch<SettingsCubit>();
// SettingsCubit settingsCubitProvider(BuildContext context, {bool listen=false}) => 
  // Provider.of<SettingsCubit>(context, listen: listen);

// P<SettingsCubit> settingsCubitProvider = P<SettingsCubit>();

// class P<T> {
//   T watch(BuildContext context) => context.watch<T>();
//   T read(BuildContext context) => context.read<T>();
// }

// TODO: add compact list mode
class SettingsForm extends StatelessWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final cubit = context.watch<SettingsCubit>();

    if (cubit.state.error != null) {
      showErrorSnackBar(
        context,
        cubit.state.error!.tr(AppLocalizations.of(context)!),
      );
    }

    return Form(
      child: ListView(
        children: [
          DropdownButtonFormField<Locale>(
            items: [
              for (final locale in AppLocalizations.supportedLocales)
                DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(locale.name),
                ),
            ],
            value: Localizations.localeOf(context),
            onChanged: (Locale? newLocale) {
              if (newLocale == null) {
                return;
              }
              cubit.updateLocale(newLocale);
            },
            decoration: InputDecoration(
              labelText: l10n.languageLabel,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

extension LocaleName on Locale {
  String get name {
    switch (languageCode) {
      case 'en':
        return 'english';
      case 'ru':
        return 'русский';
    }
    return languageCode;
  }
}
