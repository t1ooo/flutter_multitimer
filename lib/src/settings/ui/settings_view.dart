import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../style/style.dart';

import 'settings_form.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Padding(padding: pagePadding, child: SettingsForm()),
    );
  }
}
