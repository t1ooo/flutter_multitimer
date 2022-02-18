import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/gen/app_localizations.dart';
import '../util/snackbar.dart';
import 'settings_cubit.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // _localeController.value = settings.locale;
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
                  child: Text(locale.toString()),
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
