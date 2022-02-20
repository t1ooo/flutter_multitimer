import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../util/date_time.dart';
import '../../util/snackbar.dart';

import '../logic/timer.dart';
import '../logic/timer_cubit.dart';

import 'timer_edit_view.dart';

class TimerListItem extends StatelessWidget {
  const TimerListItem({
    Key? key,
  }) : super(key: key);

  static final _dateFormatHms = DateFormat('HH:mm:ss');
  static final _dateFormatMs = DateFormat('mm:ss');
  static const _iconSize = 50.0;

  String _formatCountdown(Duration countdown) {
    final inSeconds =
        (countdown.inMicroseconds / Duration.microsecondsPerSecond).round();
    final dTimer = dateTime(
      hour: inSeconds ~/ (60 * 60 * 24),
      minute: inSeconds ~/ 60,
      second: inSeconds % 60,
    );
    return ((dTimer.hour > 0) ? _dateFormatHms : _dateFormatMs).format(dTimer);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TimerCubit>();
    final clock = context.read<Clock>();

    // TODO: MAYBE: find a better solution to update TimerCubit's dependency
    cubit.setLocalizations(NotificationLocalizations.of(context));

    if (cubit.state.error != null) {
      showErrorSnackBar(
        context,
        cubit.state.error!.tr(AppLocalizations.of(context)!),
      );
    }

    final timer = cubit.state.timer;

    final countdown = timer.countdown(clock.now());
    final fmtCountdown = _formatCountdown(countdown);
    final progress =
        1 - (countdown.inMicroseconds / timer.duration.inMicroseconds);

    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timer.name, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 5),
                        Text(
                          fmtCountdown,
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  ButtonBar(
                    children: [
                      if (timer.status == TimerStatus.stop) ...[
                        _startButton(context),
                      ] else if (timer.status == TimerStatus.pause) ...[
                        _stopButton(context),
                        SizedBox(width: 10),
                        _resumeButton(context),
                      ] else ...[
                        _stopButton(context),
                        SizedBox(width: 10),
                        _pauseButton(context),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(value: progress),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TimerEditView(timer: timer)),
        );
      },
    );
  }

  Widget _startButton(BuildContext context) {
    final cubit = context.read<TimerCubit>();

    return ElevatedButton(
      child: Icon(Icons.play_arrow, size: _iconSize),
      onPressed: () {
        cubit.start();
      },
    );
  }

  Widget _stopButton(BuildContext context) {
    final cubit = context.read<TimerCubit>();

    return ElevatedButton(
      child: Icon(Icons.stop, size: _iconSize),
      onPressed: () {
        cubit.stop();
      },
    );
  }

  Widget _pauseButton(BuildContext context) {
    final cubit = context.read<TimerCubit>();

    return ElevatedButton(
      child: Icon(Icons.pause, size: _iconSize),
      onPressed: () {
        cubit.pause();
      },
    );
  }

  Widget _resumeButton(BuildContext context) {
    final cubit = context.read<TimerCubit>();

    return ElevatedButton(
      child: Icon(Icons.play_arrow_outlined, size: _iconSize),
      onPressed: () {
        cubit.resume();
      },
    );
  }
}
