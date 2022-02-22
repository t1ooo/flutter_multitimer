import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart' show BuildContext;

import '../../clock/clock.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../logging/logging.dart';
import '../../util/chaos.dart';
import 'notification_service.dart';
import 'ticker.dart';
import 'timer.dart';
import 'timer_repo.dart';

class NotificationLocalizations {
  NotificationLocalizations(this.l10n);

  factory NotificationLocalizations.of(BuildContext context) {
    return NotificationLocalizations(AppLocalizations.of(context)!);
  }

  final AppLocalizations l10n;

  String get notificationBody => l10n.notificationBody;
  String get stopSignalButton => l10n.stopSignalButton;
}

enum TimerCubitError {
  update,
}

extension TimerCubitErrorLocalizations on TimerCubitError {
  String tr(AppLocalizations l10n) {
    switch (this) {
      case TimerCubitError.update:
        return l10n.timerUpdateError;
    }
  }
}

class TimerCubitState {
  TimerCubitState({
    required this.timer,
    this.error,
  });

  final Timer timer;
  final TimerCubitError? error;

  TimerCubitState copyWith({
    Timer? timer,
    TimerCubitError? error,
  }) {
    return TimerCubitState(
      timer: timer ?? this.timer,
      error: error ?? this.error,
    );
  }
}

class TimerCubit extends Cubit<TimerCubitState> {
  TimerCubit(
    Timer timer,
    this.timerRepo,
    this.clock,
    this.notificationService,
    this.l10n, [
    this.ticker = const Ticker(),
  ]) : super(TimerCubitState(timer: timer)) {
    _init();
  }

  final TimerRepo timerRepo;
  final Clock clock;
  final NotificationService notificationService;
  final Ticker ticker;
  NotificationLocalizations l10n;
  StreamSubscription<Duration>? _tickerSub;
  static final _log = Logger('TimerCubit');

  void _init() {
    // resume started timer after app restart
    if (state.timer.status == TimerStatus.start) {
      if (state.timer.countdown(clock.now()) <= Duration.zero) {
        _log.info('timer ended when the app was not running: ${state.timer}');
        _done();
      } else {
        _resumeStarted();
      }
    }
  }

  void setLocalizations(NotificationLocalizations l10n) {
    this.l10n = l10n;
  }

  @override
  Future<void> close() async {
    _log.info('close: ${state.timer}');
    await _cancelTicker();
    await notificationService.cancel(state.timer.id);
    return super.close();
  }

  Future<void> start() async {
    final timer = state.timer.start(clock.now());
    _logTimer('start', timer);
    emit(TimerCubitState(timer: timer));

    await _listenTicker();

    // ignore: unawaited_futures
    _sendNotification(timer);
    // ignore: unawaited_futures
    _updateTimer(timer);
  }

  Future<void> _resumeStarted() async {
    final timer = state.timer.resume(clock.now());
    _logTimer('_resumeStarted', timer);
    emit(TimerCubitState(timer: timer));

    await _listenTicker();

    // no need to send a notification because we already sent a delayed notification when we started the timer

    // ignore: unawaited_futures
    _updateTimer(timer);
  }

  Future<void> stop() async {
    // ignore: unawaited_futures
    _done();

    // ignore: unawaited_futures
    notificationService.cancel(state.timer.id);
  }

  Future<void> _done() async {
    final timer = state.timer.stop();
    _logTimer('_done', timer);

    emit(TimerCubitState(timer: timer));

    await _cancelTicker();

    // ignore: unawaited_futures
    _updateTimer(timer);
  }

  Future<void> pause() async {
    final timer = state.timer.pause(clock.now());
    _logTimer('pause', timer);
    emit(TimerCubitState(timer: timer));

    await _cancelTicker();

    // ignore: unawaited_futures
    notificationService.cancel(timer.id);

    // ignore: unawaited_futures
    _updateTimer(timer);
  }

  Future<void> resume() async {
    final timer = state.timer.resume(clock.now());
    _logTimer('resume', timer);
    emit(TimerCubitState(timer: timer));

    await _listenTicker();

    // ignore: unawaited_futures
    _sendNotification(timer);

    // ignore: unawaited_futures
    _updateTimer(timer);
  }

  Future<void> _tick(Duration _) async {
    if (state.timer.countdown(clock.now()) < Duration.zero) {
      final timer = state.timer.copyWith();
      emit(TimerCubitState(timer: timer));
      await Future.delayed(Duration(seconds: 1));
      // ignore: unawaited_futures
      _done();
      return;
    }

    final timer = state.timer.copyWith();
    _logTimer('resume', timer);
    emit(TimerCubitState(timer: timer));
  }

  Future<void> _sendNotification(Timer timer) async {
    await notificationService.cancel(state.timer.id);
    await notificationService.sendDelayed(
      Notification(timer.id, timer.name, l10n.notificationBody),
      timer.countdown(clock.now()) + Duration(seconds: 1),
      [NotificationAction('stop', l10n.stopSignalButton)],
    );
  }

  Future<void> _updateTimer(Timer timer) async {
    try {
      randomException();
      await asyncRandomDelay();
      await timerRepo.update(timer);
    } on Exception catch (e) {
      _handleError(e, TimerCubitError.update);
    }
  }

  void _handleError(Exception e, TimerCubitError error) {
    _log.error('', e);
    emit(state.copyWith(error: error)); // set error, keep the previous timers
  }

  void _logTimer(String method, Timer timer) {
    _log.info('$method: $timer, ${timer.countdown(clock.now())}');
  }

  Future<void> _listenTicker() async {
    await _tickerSub?.cancel();
    _tickerSub = ticker.tick().listen(_tick);
  }

  Future<void> _cancelTicker() async {
    await _tickerSub?.cancel();
  }
}
