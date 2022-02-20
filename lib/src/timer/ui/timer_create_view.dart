import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../style/style.dart';

import '../logic/timer.dart';

import 'timer_form.dart';

class TimerCreateView extends StatelessWidget {
  const TimerCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final clock = context.read<Clock>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timerCreateTitle),
      ),
      body: Padding(
        padding: pagePadding,
        child: TimerForm(timer: _draftTimer(l10n, clock.now()), isNew: true),
      ),
    );
  }

  Timer _draftTimer(AppLocalizations l10n, DateTime now) {
    return Timer.initial(
      id: 0,
      name: l10n.timerNameDraft,
      duration: Duration(minutes: 5),
      now: DateTime.now(),
    );
  }
}
