import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';
import '../util/date_time.dart';
import '../util/snackbar.dart';
import 'notification_service.dart';
import 'timer.dart';
import 'timer_cubit.dart';
import 'timer_edit_view.dart';

class TimerListItem extends StatelessWidget {
  const TimerListItem({
    Key? key,
  }) : super(key: key);

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

    const iconSize = 40.0;
    // timer.countdown.inSeconds
    final countdown = timer.countdown(clock.now());
    final fmtCountdown = _formatCountdown(countdown);
    final progress =
        1 - (countdown.inMicroseconds / timer.duration.inMicroseconds);

    return GestureDetector(
      child: Card(
        child: Padding(
          // padding: pagePadding,
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${timer.name} ${timer.id}'),
                      SizedBox(height: 5),
                      Text(
                        fmtCountdown,
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                  ButtonBar(
                    children: [
                      if (timer.status == TimerStatus.stop) ...[
                        ElevatedButton(
                          child: Icon(Icons.play_arrow, size: iconSize),
                          onPressed: () {
                            cubit.start();
                          },
                        )
                      ] else if (timer.status == TimerStatus.pause) ...[
                        ElevatedButton(
                          child: Icon(Icons.stop, size: iconSize),
                          onPressed: () {
                            cubit.stop();
                          },
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          child: Icon(Icons.play_arrow, size: iconSize),
                          onPressed: () {
                            cubit.start();
                          },
                        ),
                      ] else ...[
                        ElevatedButton(
                          child: Icon(Icons.stop, size: iconSize),
                          onPressed: () {
                            cubit.stop();
                          },
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          child: Icon(Icons.pause, size: iconSize),
                          onPressed: () {
                            cubit.pause();
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(value: progress),
              // SizedBox(height: 10),
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
}

final _dateFormat = DateFormat('HH:mm:ss');

String _formatCountdown(Duration countdown) {
  final inSeconds =
      (countdown.inMicroseconds / Duration.microsecondsPerSecond).round();
  final dTimer = dateTime(
    hour: inSeconds ~/ (60 * 60 * 24),
    minute: inSeconds ~/ 60,
    second: inSeconds % 60,
  );
  return _dateFormat.format(dTimer);
}
