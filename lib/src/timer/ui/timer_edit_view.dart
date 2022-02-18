import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../style/style.dart';

import '../logic/timer.dart';

import 'timer_form.dart';

class TimerEditView extends StatelessWidget {
  const TimerEditView({Key? key, required this.timer}) : super(key: key);

  final Timer timer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timerEditTitle),
      ),
      body: Padding(
        padding: pagePadding,
        child: TimerForm(timer: timer, isNew: false),
      ),
    );
  }
}
