import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../settings/ui/settings_view.dart';
import '../../timer/ui/timer_create_view.dart';
import '../../timer/ui/timer_list.dart';
import '../../util/debug.dart';
import '../../util/shared_prefs.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
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
            whenDebug(
              () => ListTile(
                title: Text('clear shared_preferences'),
                onTap: () {
                  clearSharedPreferences();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: TimerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TimerCreateView(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
