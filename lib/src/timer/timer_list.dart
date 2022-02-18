import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/gen/app_localizations.dart';
import '../util/snackbar.dart';
import 'notification_service.dart';
import 'timer_cubit.dart';
import 'timer_list_item.dart';
import 'timer_repo.dart';
import 'timers_cubit.dart';

class TimerList extends StatelessWidget {
  const TimerList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TimersCubit>();

    if (cubit.state.error != null) {
      showErrorSnackBar(
        context,
        cubit.state.error!.tr(AppLocalizations.of(context)!),
      );
    }
    if (cubit.state.timers == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        for (final timer in cubit.state.timers!)
          BlocProvider(
            // we need key in BlocProvider to update TimerCubit when timer is updated
            key: Key('${timer.id} ${timer.lastUpdate}'),
            create: (_) => TimerCubit(
              timer,
              context.read<TimerRepo>(),
              context.read<Clock>(),
              context.read<NotificationService>(),
              NotificationLocalizations.of(context),
            ), //..setLocalizations(NotificationLocalizations.of(context)),

            child: TimerListItem(/* key: Key(timer.id.toString()) */),
          ),
      ],
    );
  }
}