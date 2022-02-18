import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../style/style.dart';

import '../logic/timer.dart';

import 'timer_form.dart';

class TimerCreateView extends StatelessWidget {
  const TimerCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timerCreateTitle),
      ),
      body: Padding(
        padding: pagePadding,
        child: TimerForm(timer: draftTimer(), isNew: true),
      ),
    );
  }
}
