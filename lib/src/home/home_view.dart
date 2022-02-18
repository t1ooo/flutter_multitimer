import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/gen/app_localizations.dart';
import '../settings/settings_view.dart';
import '../timer/timer_create_button.dart';
import '../timer/timer_list.dart';
import '../util/shared_prefs.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timers'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(l10n.appTitle),
            ),
            ListTile(
              title: Text(l10n.settingsTitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsView(),
                  ),
                ).then((_) => Navigator.pop(context));
              },
            ),
            if (kDebugMode)
              ListTile(
                title: Text('clear shared_preferences'),
                onTap: () {
                  clearSharedPreferences();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: TimerList(),
      floatingActionButton: TimerCreateButton(),
    );
  }
}
