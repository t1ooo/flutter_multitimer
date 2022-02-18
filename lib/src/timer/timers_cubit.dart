
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import '../util/chaos.dart';
import '../l10n/gen/app_localizations.dart';
import '../logging/logging.dart';
import 'timer.dart';
import 'timer_repo.dart';

enum TimersCubitError {
  load,
  create,
  update,
  delete,
}

extension TimersCubitErrorLocalizations on TimersCubitError {
  String tr(AppLocalizations l10n) {
    switch (this) {
      case TimersCubitError.load:
        return l10n.timersLoadError;
      case TimersCubitError.create:
        return l10n.timerCreateError;
      case TimersCubitError.update:
        return l10n.timerUpdateError;
      case TimersCubitError.delete:
        return l10n.timerDeleteError;
    }
  }
}

class TimersCubitState extends Equatable {
  const TimersCubitState({
    this.timers,
    this.error,
  });

  final List<Timer>? timers;
  final TimersCubitError? error;

  @override
  List<Object?> get props => [timers, error];

  TimersCubitState copyWith({
    List<Timer>? timers,
    TimersCubitError? error,
  }) {
    return TimersCubitState(
      timers: timers ?? this.timers,
      error: error ?? this.error,
    );
  }
}

class TimersCubit extends Cubit<TimersCubitState> {
  TimersCubit(this.timerRepo, this.clock) : super(TimersCubitState());

  // Future<List<Timer>>? _timers;
  final TimerRepo timerRepo;
  final Clock clock;
  static final _log = Logger('TimersCubit');

  Future<void> load() async {
    try {
      final timers = await timerRepo.list();
      await _emitState(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e, TimersCubitError.load);
    }
  }

  Future<void> create(Timer timer) async {
    _log.info('create');
    try {
      await timerRepo.create(timer.stop());
      final timers = await timerRepo.list();
      await _emitState(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e, TimersCubitError.create);
    }
  }

  Future<void> update(Timer timer) async {
    _log.info('update');

    try {
      // for automatically update TimerCubit (and cancel previous notification) we could
      //    1. update timer inself and use composite key (for example Timer.id + Timer.lastUpdateDateTime) in BlocProvider
      //      cons: we need extra field (lastUpdateDateTime) in Timer
      //    2. recreate timer with new id and use Timer.id as key in BlocProvider
      //      cons: we need to sort timers because recreated timer will move to the end of the list

      await timerRepo.update(
        timer.copyWith(
          rest: timer.duration,
          lastUpdate: clock.now(),
          status: TimerStatus.stop,
        ),
      );
      final timers = await timerRepo.list();
      await _emitState(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e, TimersCubitError.update);
    }
  }

  Future<void> delete(Timer timer) async {
    try {
      await timerRepo.delete(timer);
      final timers = await timerRepo.list();
      await _emitState(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e, TimersCubitError.delete);
    }
  }

  Future<void> _emitState(TimersCubitState newState) async {
    randomException();
    await asyncRandomDelay();
    emit(newState);
  }

  void _handleError(Exception e, TimersCubitError error) {
    _log.error('', e);
    emit(state.copyWith(error: error)); // set error, keep the previous timers
  }
}
