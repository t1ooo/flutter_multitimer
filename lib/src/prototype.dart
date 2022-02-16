// TODO: enable all analysis_options.yaml
// TODO: Navigator.pushNamed
// TODO: nullable Settings.locale, add init to Repo
// TODO: remove countdown field, calculate countdown

import 'dart:async' as async;
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/gen/app_localizations.dart';
import 'settings.dart';
import 'settings_repository.dart';
import 'utils/chaos_uitls.dart';

// const dismissNotificationAfter = Duration(seconds: 10);

// class FirstRun {
//   final _key = '_is_first_run';
//   bool? _isFirstRun;

//   bool? get isFirstRun => _isFirstRun;

//   Future<void> check() async {
//     if (_isFirstRun != null) {
//       return;
//     }
//     final prefs = await SharedPreferences.getInstance();
//     if (prefs.containsKey(_key)) {
//       _isFirstRun = false;
//       return;
//     }

//     prefs.setBool(_key, true);
//     _isFirstRun = true;
//   }

//   Future<void> reset() async {
//      final prefs = await SharedPreferences.getInstance();
//      prefs.remove(_key);
//   }
// }

class FirstRun {
  static const _key = '_is_first_run';
  bool _isFirstRun;

  FirstRun._(this._isFirstRun);

  bool get isFirstRun => _isFirstRun;

  static Future<FirstRun> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_key)) {
      return FirstRun._(false);
    }

    prefs.setBool(_key, true);
    return FirstRun._(true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_key);
    _isFirstRun = true;
  }
}

extension LoggerExt on Logger {
  void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    severe(message, error, stackTrace);
  }
}

class Notification extends Equatable {
  final int id;
  final String title;
  final String body;
  Notification(this.id, this.title, this.body);

  @override
  List<Object?> get props => [id, title, body];
}

abstract class NotificationService {
  Future<void> sendDelayed(
    Notification notification,
    Duration delay, [
    List<NotificationAction>? actions,
  ]);
  Future<void> cancel(int id);
  Future<void> dismiss(int id);
  Future<void> dispose();

  // void setLocalizations(NotificationLocalizations l10n);
}

class TimerNotificationService implements NotificationService {
  static final _log = Logger('NotificationService');
  final _timers = <int, async.Timer>{};

  @override
  Future<void> sendDelayed(
    Notification notification,
    Duration delay, [
    List<NotificationAction>? actions,
  ]) async {
    _log.info('register: $notification');
    final timer = async.Timer(delay, () => _log.info('fire: $notification'));
    _timers[notification.id] = timer;
  }

  @override
  Future<void> cancel(int id) async {
    _log.info('cancel: $id');
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  @override
  Future<void> dismiss(int id) async {
    return;
  }

  @override
  async.Future<void> dispose() async {
    return;
  }

  // @override
  // void setLocalizations(NotificationLocalizations l10n) {
  //   return;
  // }
}

class NotificationLocalizations {
  NotificationLocalizations(this.l10n);

  factory NotificationLocalizations.of(BuildContext context) {
    return NotificationLocalizations(AppLocalizations.of(context)!);
  }

  final AppLocalizations l10n;

  String get notificationBody => l10n.notificationBody;
  String get stopSignalButton => l10n.stopSignalButton;

  // String get notificationBody => null;
}

class NotificationAction {
  final String key;
  final String label;

  NotificationAction(this.key, this.label);
}

class AwesomeNotificationService implements NotificationService {
  final String key;
  final String name;
  final String description;
  // final bool updateChannel;
  // NotificationLocalizations l10n;
  // bool _isReady = false;

  static final _log = Logger('AwesomeNotificationService');

  // AwesomeNotificationService({
  //   required this.key,
  //   required this.name,
  //   required this.description,
  //   // required this.l10n,
  //   this.updateChannel = false,
  // });

  // @override
  // void setLocalizations(NotificationLocalizations l10n) {
  //   this.l10n = l10n;
  // }

  AwesomeNotificationService._({
    required this.key,
    required this.name,
    required this.description,
  });

  @override
  Future<void> dispose() async {
    AwesomeNotifications().dispose();
  }

  static Future<AwesomeNotificationService> init({
    required String key,
    required String name,
    required String description,
    bool updateChannel = false,
  }) async {
    final notificationChannel = NotificationChannel(
      channelKey: key,
      channelName: name,
      channelDescription: description,
      importance: NotificationImportance.Max,
      playSound: false,
      defaultPrivacy: NotificationPrivacy.Public,
    );

    await AwesomeNotifications().initialize(null, []);
    if (updateChannel) {
      await AwesomeNotifications().removeChannel(key);
    }
    await AwesomeNotifications().setChannel(
      notificationChannel,
      forceUpdate: false,
    );
    return AwesomeNotificationService._(
      key: key,
      name: name,
      description: description,
    );
  }

  @override
  async.Future<void> cancel(int id) async {
    // await _init();
    _log.info('cancel: $id');
    await AwesomeNotifications().cancel(id);
  }

  @override
  async.Future<void> dismiss(int id) async {
    // await _init();
    _log.info('dismiss: $id');
    await AwesomeNotifications().dismiss(id);
  }

  @override
  async.Future<void> sendDelayed(
    Notification notification,
    Duration delay, [
    List<NotificationAction>? actions,
  ]) async {
    // await _init();
    _log.info('sendDelayed: $notification, $delay');
    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();
    // String utcTimeZone =
    // await AwesomeNotifications().getLocalTimeZoneIdentifier();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notification.id,
        channelKey: key,
        title: notification.title,
        body: notification.body,
        wakeUpScreen: true,
        fullScreenIntent: true,
        category: NotificationCategory.Alarm,
      ),
      schedule: NotificationInterval(
        interval: delay.inSeconds,
        timeZone: localTimeZone,
        preciseAlarm: true,
        repeats: false,
        // timezone: utcTimeZone,
      ),
      // actionButtons: [_notificationActionButton('stop', l10n.stopSignalButton)],
      actionButtons: actions?.map(_notificationActionButton).toList(),
    );
  }

  static NotificationActionButton _notificationActionButton(
    NotificationAction action,
  ) {
    return NotificationActionButton(
      key: action.key,
      label: action.label,
      autoDismissible: true,
      showInCompactView: true,
      buttonType: ActionButtonType.KeepOnTop,
    );
  }
}

// class SnackBarNotification implements NotificationService {
//   final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
//   NotificationLocalizations l10n;
//   static final _log = Logger('SnackBarNotification');

//   SnackBarNotification(this.scaffoldMessengerKey, this.l10n);

//   @override
//   async.Future<void> cancel(int id) {
//     // TODO: implement cancel
//     throw UnimplementedError();
//   }

//   @override
//   async.Future<void> dismiss(int id) {
//     // TODO: implement dismiss
//     throw UnimplementedError();
//   }

//   @override
//   async.Future<void> sendDelayed(Notification notification, Duration delay) {
//     // TODO: implement sendDelayed
//     throw UnimplementedError();
//   }

//   @override
//   void setLocalizations(NotificationLocalizations l10n) {
//     this.l10n = l10n;
//   }

//   void _showSnackBar(SnackBar Function(BuildContext) snackBarBuilder) {
//     // WidgetsBinding.instance?.addPostFrameCallback((_) {
//     final currentState = scaffoldMessengerKey.currentState;
//     if (currentState == null) {
//       _log.info('currentState is empty; return');
//       return;
//     }
//     // final currentContext = navigatorKey.currentContext;
//     // if (currentContext == null) {
//     //   _log.info('currentContext is empty; return');
//     //   return;
//     // }
//     currentState.hideCurrentSnackBar();
//     currentState.showSnackBar(snackBarBuilder());
//     // });
//   }

//   void _hideCurrentSnackBar() {
//     // WidgetsBinding.instance?.addPostFrameCallback((_) {
//     final currentState = scaffoldMessengerKey.currentState;
//     if (currentState == null) {
//       return;
//     }
//     currentState.hideCurrentSnackBar();
//     // });
//   }

//   SnackBar _buildSnackBar() {
//     // final l10n = appLocalizations(context);

//     return SnackBar(
//       content: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(l10n.notificationBody),
//           ButtonBar(
//             children: [
//               ElevatedButton(
//                 onPressed: () => {}, // TODO,
//                 child: Text(l10n.stopSignalButton),
//               ),
//               // ElevatedButton(
//               //   onPressed: alarmRunnerClient.snooze,
//               //   child: Text(l10n.notificationSnoozeButton),
//               // ),
//             ],
//           ),
//         ],
//       ),
//       duration: Duration(days: 365),
//     );
//   // }
// }

abstract class TimerRepo {
  Future<List<Timer>> list();
  Future<Timer> create(Timer timer);
  Future<void> update(Timer timer);
  Future<void> delete(Timer timer);
}

class InMemoryTimerRepo implements TimerRepo {
  static final _log = Logger('TimerRepo');
  final _timers = <int, Timer>{};

  Future<List<Timer>> list() async {
    await _delay();
    return _timers.values.toList();
  }

  Future<Timer> create(Timer timer) async {
    // if (_timers.containsKey(timer.id)) {
    //   throw Exception('already exists');
    // }
    _log.info('create: $timer');
    final id = _genId();
    final timerWithId = timer.copyWith(id: id);
    _log.info('create: $timerWithId');
    _timers[id] = timerWithId;
    return timerWithId;
  }

  Future<void> update(Timer timer) async {
    _log.info('update: $timer');
    if (!_timers.containsKey(timer.id)) {
      throw Exception('not found');
      // return;
    }
    _timers[timer.id] = timer;
  }

  Future<void> delete(Timer timer) async {
    _log.info('delete: $timer');
    _timers.remove(timer.id);
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 500), null);
  }

  int _id = 0;
  int _genId() {
    _id++;
    return _id;
  }
}

DateTime dateTime({
  int year = 0,
  int month = 1,
  int day = 1,
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
  int microsecond = 0,
}) {
  return DateTime(
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond,
  );
}

enum TimerStatus {
  // ready,
  start,
  stop,
  pause,
  // resume,
}

class Timer extends Equatable {
  final int id;
  final String name;
  final Duration duration;
  final Duration rest;
  final TimerStatus status;
  final DateTime lastUpdate;
  final DateTime startedAt;

  Timer({
    required this.id,
    required this.name,
    required this.duration,
    required this.rest,
    required this.status,
    required this.lastUpdate,
    required this.startedAt,
  });

  // Timer.stopped({
  //   required this.id,
  //   required this.name,
  //   required this.duration,
  // })  : countdown = duration,
  //       status = TimerStatus.stop;

  Duration calculateCountdown(DateTime now) {
    if (status == TimerStatus.start /* || status == TimerStatus.pause */) {
      final stopAt = startedAt.add(rest);
      final countdown = stopAt.difference(now);
      print('$rest, $countdown');
      return countdown;
    }
    return rest;
  }

  Timer copyWith({
    int? id,
    String? name,
    Duration? duration,
    Duration? rest,
    TimerStatus? status,
    DateTime? lastUpdate,
    DateTime? startedAt,
  }) {
    return Timer(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      rest: rest ?? this.rest,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, duration, rest, status, lastUpdate, startedAt];
}

Timer draftTimer() {
  return Timer(
    id: 0,
    name: 'timer',
    duration: Duration(minutes: 5),
    rest: Duration(minutes: 5),
    status: TimerStatus.stop,
    lastUpdate: DateTime.now(),
    startedAt: DateTime.now(),
  );
}

// class TimerLocalizations {
//   TimerLocalizations([this.l10n]);

//   factory TimerLocalizations.of(BuildContext context) {
//     return TimerLocalizations(AppLocalizations.of(context));
//   }

//   final AppLocalizations? l10n;

//   String get defaultName => 'timer';
// }

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
  final List<Timer>? timers;
  final TimersCubitError? error;

  TimersCubitState({
    this.timers,
    this.error,
  });

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

  // void increment() => emit(state + 1);
  // void decrement() => emit(state - 1);
  Future<void> load() async {
    try {
      var timers = await timerRepo.list();
      await _emitState(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e, TimersCubitError.load);
    }
    // await Future.delayed(Duration(milliseconds: 500), null);
    // emit(TimersCubitState(timers: [
    //   Timer(
    //     id: 'a',
    //     name: 'stop',
    //     duration: Duration(seconds: 60 * 60 * 2),
    //     countdown: Duration(seconds: 60 * 60 * 2),
    //     status: TimerStatus.stop,
    //   ),
    //   Timer(
    //     id: 'b',
    //     name: 'start',
    //     duration: Duration(seconds: 125),
    //     countdown: Duration(seconds: 125),
    //     status: TimerStatus.start,
    //   ),
    //   Timer(
    //     id: 'c',
    //     name: 'pause',
    //     duration: Duration(seconds: 5),
    //     countdown: Duration(seconds: 5),
    //     status: TimerStatus.pause,
    //   ),
    // ]));
  }

  Future<void> create(Timer timer) async {
    _log.info('create');
    try {
      await timerRepo.create(timer.copyWith(
        rest: timer.duration,
        lastUpdate: clock.now(),
        status: TimerStatus.stop,
      ));
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

      await timerRepo.update(timer.copyWith(
        rest: timer.duration,
        lastUpdate: clock.now(),
        status: TimerStatus.stop,
      ));

      // await timerRepo.delete(timer);
      // await timerRepo.create(timer.copyWith(
      //   countdown: timer.duration,
      //   lastUpdate: clock.now(),
      //   status: TimerStatus.stop,
      // ));

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

  // Future<void> start(Timer timer) async {}
  // Future<void> stop(Timer timer) async {}
  // Future<void> pause(Timer timer) async {}
  // Future<void> resume(Timer timer) async {}
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
  final Timer timer;
  final TimerCubitError? error;

  TimerCubitState({
    required this.timer,
    this.error,
  });

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
    this.saveInterval = const Duration(seconds: 10),
    this.ticker = const Ticker(),
  ]) : super(TimerCubitState(timer: timer)) {
    if (saveInterval < const Duration(seconds: 1)) {
      throw Exception('saveInterval should be >= than 1 second');
    }
    _init();
  }

  final NotificationService notificationService;

  /// delay between saving the current state of the timer to the repository
  final Duration saveInterval;
  final TimerRepo timerRepo;
  final Clock clock;
  final Ticker ticker;
  async.StreamSubscription<Duration>? _tickerSub;
  NotificationLocalizations l10n;
  static final _log = Logger('TimerCubit');
  // static const notificationId = 0;

  void _init() {
    if (state.timer.status == TimerStatus.start) {
      // final stopAt = state.timer.startedAt.add(state.timer.countdown);
      // final countdown = stopAt.difference(clock.now()) + Duration(seconds: 2);
      final countdown = state.timer.calculateCountdown(clock.now());
      if (countdown <= Duration.zero) {
        _log.info('timer ended when the app was not running: ${state.timer}');
        _done();
      } else {
        _restart(countdown);
      }
      // if (clock
      //     .now()
      //     .isAfter(state.timer.startedAt.add(state.timer.countdown))) {
      //   _log.info('done when the app was not running');
      //   _done();
      // } else {
      //   start();
      // }
    }
  }

  @override
  Future<void> close() {
    _log.info('close: ${state.timer}');
    _tickerSub?.cancel();
    // TODO: is it working correctly? maybe should be canceled in TimersCubit
    notificationService.cancel(state.timer.id);
    return super.close();
  }

  Future<void> start() async {
    final timer = state.timer.copyWith(
      status: TimerStatus.start,
      startedAt: clock.now(),
    );
    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();
    _tickerSub = ticker.tick(state.timer.duration).listen(_tick);

    _sendNotification(timer);
    _updateTimer(timer);
  }

  /// restart timer after app restart
  Future<void> _restart(Duration countdown) async {
    final timer = state.timer.copyWith(
      // status: TimerStatus.start,
      startedAt: clock.now(),
      // rest: countdown,
    );
    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();
    _tickerSub = ticker.tick(state.timer.duration).listen(_tick);

    _sendNotification(timer);

    _updateTimer(timer);
  }

  Future<void> stop() async {
    _done();

    notificationService.cancel(state.timer.id);
  }

  Future<void> _done() async {
    final timer = state.timer.copyWith(
      status: TimerStatus.stop,
      rest: state.timer.duration,
    );
    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();

    _updateTimer(timer);
  }

  Future<void> pause() async {
    final timer = state.timer.copyWith(
      status: TimerStatus.pause,
      rest: state.timer.calculateCountdown(clock.now()),
    );
    emit(TimerCubitState(timer: timer));

    _tickerSub?.pause();

    notificationService.cancel(timer.id);

    _updateTimer(timer);
  }

  Future<void> resume() async {
    final timer = state.timer.copyWith(
      status: TimerStatus.start,
      startedAt: clock.now(),
    );
    emit(TimerCubitState(timer: timer));

    _tickerSub?.resume();

    _sendNotification(timer);

    _updateTimer(timer);
  }

  Future<void> _tick(Duration countdown) async {
    if (countdown.inSeconds <= 0) {
      _done();
      return;
    }

    // final timer = state.timer.copyWith(countdown: countdown);
    final timer = state.timer.copyWith();
    emit(TimerCubitState(timer: timer));

    // if (countdown.inSeconds % saveInterval.inSeconds == 0) {
    // _updateTimer(timer);
    // }
  }

  Future<void> _sendNotification(Timer timer) async {
    await notificationService.cancel(state.timer.id);
    await notificationService.sendDelayed(
      Notification(timer.id, timer.name, l10n.notificationBody),
      timer.calculateCountdown(clock.now()),
      [NotificationAction('stop', l10n.stopSignalButton)],
    );
  }

  Future<void> _updateTimer(Timer timer) async {
    try {
      randomException();
      await asyncRandomDelay();
      timerRepo.update(timer);
    } on Exception catch (e) {
      _handleError(e, TimerCubitError.update);
    }
  }

  void setLocalizations(NotificationLocalizations l10n) {
    // print('setLocalizations');
    this.l10n = l10n;
  }

  // Future<void> _emitState(TimerCubitState newState) async {
  //   randomException();
  //   await asyncRandomDelay();
  //   emit(newState);
  // }

  void _handleError(Exception e, TimerCubitError error) {
    _log.error('', e);
    emit(state.copyWith(error: error)); // set error, keep the previous timers
  }
}

class Ticker {
  const Ticker();
  Stream<Duration> tick(Duration duration) {
    final ticks = duration.inSeconds;
    return Stream.periodic(
      Duration(seconds: 1),
      (x) => Duration(seconds: ticks - x - 1),
    ).take(ticks);
  }
}

// final timersCubit = TimersCubit()..load();

// UI --------------------------------------

final dateFormat = DateFormat('HH:mm:ss');
const pagePadding = EdgeInsets.all(20);
// const pagePadding = EdgeInsets.symmetric(vertical: 20, horizontal: 20);

DateTime dateTimeFromDuration(Duration duration) {
  return dateTime(
    hour: duration.inSeconds ~/ (60 * 60 * 24),
    minute: duration.inSeconds ~/ 60,
    second: duration.inSeconds % 60,
  );
}

String formatCountdown(Duration countdown) {
  return dateFormat.format(dateTimeFromDuration(countdown));
}

class HomeView extends StatelessWidget {
  HomeView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      // body: TimerList(),
      // body: BlocProvider(
      // create: (_) => TimersCubit()..load(),
      // child: TimerList(),
      // ),
      body: TimerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    TimerEditView(timer: draftTimer(), isNew: true)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void showErrorSnackBar(BuildContext context, String error) {
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  });
}

class TimerList extends StatelessWidget {
  TimerList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TimersCubit>();

    if (cubit.state.error != null) {
      // return Text(cubit.state.error!.tr(AppLocalizations.of(context)!));
      showErrorSnackBar(
        context,
        cubit.state.error!.tr(AppLocalizations.of(context)!),
      );
    }
    if (cubit.state.timers == null) {
      return Center(child: CircularProgressIndicator());
    }
    // print(AppLocalizations.of(context));
    return ListView(
      // direction: Axis.vertical,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final timer in cubit.state.timers!)
          BlocProvider(
            // we need key in BlocProvider to update TimerCubit when timer is updated
            // TODO: remove lastUpdate from Timer, replace key to {timer.id timer.status}
            key: Key('${timer.id} ${timer.lastUpdate}'),
            // key: Key('${timer.id} ${timer.status}'),
            // key: Key('${timer.id}'),
            create: (_) => TimerCubit(
              timer,
              context.read<TimerRepo>(),
              context.read<Clock>(),
              context.read<NotificationService>(),
              NotificationLocalizations.of(context),
            ), //..setLocalizations(NotificationLocalizations.of(context)),
            // create: (_) {
            //   final timerCubit = TimerCubit(
            //     timer,
            //     context.read<TimerRepo>(),
            //     context.read<Clock>(),
            //     context.read<NotificationService>(),
            //     NotificationLocalizations.of(context),
            //   );
            //   context.read<SettingsCubit>().stream.listen((event) {
            //     // print(event);
            //     // print(AppLocalizations.of(context));
            //     timerCubit
            //         .setLocalizations(NotificationLocalizations.of(context));
            //   });
            //   return timerCubit;
            // }, //..setLocalizations(NotificationLocalizations.of(context)),
            child: TimerListItem(/* key: Key(timer.id.toString()) */),
          ),
        // TimerListItemV2(
        //   key: Key('${timer.id} ${timer.lastUpdate}'),
        //   timer: timer,
        // ),
        // BlocBuilder<TimerCubit, TimerCubitState>(
        //   bloc: TimerCubit(timer),
        //   builder: (BuildContext context, state) { return Container(); },
        //   // child: TimerListItem(),
        // ),
        // TimerListItemV2(timer: timer)
      ],
    );
  }
}

// class TimerListItemV3 extends StatelessWidget {
//   TimerListItemV3({
//     Key? key,
//     required this.timer,
//   }) : super(key: key);

//   Timer timer;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => TimerCubit(timer, Ticker()),
//       child: TimerListItem(),
//     );
//   }
// }

// class TimerListItemV2 extends StatefulWidget {
//   TimerListItemV2({
//     Key? key,
//     required this.timer,
//   }) : super(key: key);

//   Timer timer;

//   @override
//   State<TimerListItemV2> createState() => _TimerListItemV2State();
// }

// class _TimerListItemV2State extends State<TimerListItemV2> {
//   late TimerCubit cubit;

//   @override
//   void initState() {
//     cubit = TimerCubit(widget.timer, Ticker());
//     super.initState();
//   }

//   @override
//   void dispose() {
//     cubit.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<TimerCubit, TimerCubitState>(
//       bloc: cubit,
//       builder: builder,
//     );
//   }

//   Widget builder(BuildContext context, TimerCubitState state) {
//     if (state.error != null) {
//       return Text(state.error.toString());
//     }

//     final timer = state.timer;
//     // print(timer.id);

//     const iconSize = 45.0;
//     // timer.countdown.inSeconds
//     final fmtCountdown = dateFormat.format(dateTime(
//       hour: timer.countdown.inSeconds ~/ (60 * 60),
//       minute: timer.countdown.inSeconds ~/ 60,
//       second: timer.countdown.inSeconds % 60,
//     ));

//     return InkWell(
//       child: Padding(
//         // padding: pagePadding,
//         padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
//         child: Column(
//           // mainAxisAlignment: MainAxisAlignment.center,
//           // crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Text('name'),
//             // SizedBox(height: 5),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Row(
//                 //   crossAxisAlignment: CrossAxisAlignment.baseline,
//                 //   textBaseline: TextBaseline.ideographic,
//                 //   children: [
//                 //     Text(
//                 //       '00:24:00',
//                 //       style: TextStyle(fontSize: 25),
//                 //     ),
//                 //     // SizedBox(width: 10),
//                 //     // Text(timer.name),
//                 //   ],

//                 // ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(timer.name),
//                     SizedBox(height: 5),
//                     Text(
//                       fmtCountdown,
//                       style: TextStyle(fontSize: 25),
//                     ),
//                   ],
//                 ),
//                 // Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
//                 ButtonBar(
//                     // alignment: MainAxisAlignment.end,
//                     children: [
//                       if (timer.status == TimerStatus.stop) ...[
//                         ElevatedButton(
//                           child: Icon(Icons.play_arrow, size: iconSize),
//                           onPressed: () {
//                             cubit.start();
//                           },
//                         )
//                       ] else if (timer.status == TimerStatus.pause) ...[
//                         ElevatedButton(
//                           child: Icon(Icons.stop, size: iconSize),
//                           onPressed: () {
//                             cubit.stop();
//                           },
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           child: Icon(Icons.play_arrow, size: iconSize),
//                           onPressed: () {
//                             cubit.start();
//                           },
//                         ),
//                       ] else ...[
//                         ElevatedButton(
//                           child: Icon(Icons.stop, size: iconSize),
//                           onPressed: () {
//                             cubit.stop();
//                           },
//                         ),
//                         SizedBox(width: 10),
//                         ElevatedButton(
//                           child: Icon(Icons.pause, size: iconSize),
//                           onPressed: () {
//                             cubit.pause();
//                           },
//                         ),
//                       ],
//                     ]),
//               ],
//             ),
//             SizedBox(height: 10),
//             LinearProgressIndicator(value: 0.5),
//           ],
//         ),
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => TimerEditView()),
//         );
//       },
//     );
//   }
// }

class TimerListItem extends StatelessWidget {
  TimerListItem({
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
    final fmtCountdown = formatCountdown(timer.calculateCountdown(clock.now()));

    return InkWell(
      child: Padding(
        // padding: pagePadding,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('name'),
            // SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.baseline,
                //   textBaseline: TextBaseline.ideographic,
                //   children: [
                //     Text(
                //       '00:24:00',
                //       style: TextStyle(fontSize: 25),
                //     ),
                //     // SizedBox(width: 10),
                //     // Text(timer.name),
                //   ],

                // ),
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
                // Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
                ButtonBar(
                    // alignment: MainAxisAlignment.end,
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
                    ]),
              ],
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(value: 0.5),
          ],
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

class TimerListItemV2 extends StatelessWidget {
  TimerListItemV2({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final Timer timer;

  @override
  Widget build(BuildContext context) {
    // return BlocBuilder<TimerCubit, TimerCubitState>(
    //   bloc: TimerCubit(
    //     timer,
    //     context.read<TimerRepo>(),
    //     context.read<Clock>(),
    //     context.read<NotificationService>(),
    //     NotificationLocalizations.of(context),
    //   ),
    //   builder: builder,
    // );
    return BlocProvider(
      // we need key in BlocProvider to update TimerCubit when timer is updated
      // TODO: remove lastUpdate from Timer, replace key to {timer.id timer.status}
      // key: Key('${timer.id} ${timer.lastUpdate}'),
      // key: Key('${timer.id} ${timer.status}'),
      // key: Key('${timer.id}'),
      create: (_) => TimerCubit(
        timer,
        context.read<TimerRepo>(),
        context.read<Clock>(),
        context.read<NotificationService>(),
        NotificationLocalizations.of(context),
        // ..setLocalizations(NotificationLocalizations.of(context)),
      ), //..setLocalizations(NotificationLocalizations.of(context)),
      child: TimerListItem(/* key: Key(timer.id.toString()) */),
    );
  }

  Widget builder(BuildContext context) {
    final cubit = context.watch<TimerCubit>();
    final clock = context.read<Clock>();

    if (cubit.state.error != null) {
      showErrorSnackBar(
        context,
        cubit.state.error!.tr(AppLocalizations.of(context)!),
      );
    }

    final timer = cubit.state.timer;

    const iconSize = 40.0;
    // timer.countdown.inSeconds
    final fmtCountdown = formatCountdown(timer.calculateCountdown(clock.now()));

    return InkWell(
      child: Padding(
        // padding: pagePadding,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('name'),
            // SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.baseline,
                //   textBaseline: TextBaseline.ideographic,
                //   children: [
                //     Text(
                //       '00:24:00',
                //       style: TextStyle(fontSize: 25),
                //     ),
                //     // SizedBox(width: 10),
                //     // Text(timer.name),
                //   ],

                // ),
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
                // Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
                ButtonBar(
                    // alignment: MainAxisAlignment.end,
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
                    ]),
              ],
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(value: 0.5),
          ],
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

class TimerEditView extends StatelessWidget {
  TimerEditView({Key? key, required this.timer, this.isNew = false})
      : super(key: key);

  final bool isNew;
  final Timer timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timer'),
      ),
      body: TimerEdit(timer: timer, isNew: isNew),
    );
  }
}

class TimerEdit extends StatelessWidget {
  TimerEdit({Key? key, required this.timer, this.isNew = false})
      : super(key: key);

  static final hourController = TextEditingController();
  static final minuteController = TextEditingController();
  static final secondController = TextEditingController();
  static final nameController = TextEditingController();

  final bool isNew;
  final Timer timer;

  String _format(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final verticalPadding = SizedBox(height: 30);

    final cubit = context.read<TimersCubit>();

    final durationDateTime = dateTimeFromDuration(timer.duration);
    hourController.text = _format(durationDateTime.hour);
    minuteController.text = _format(durationDateTime.minute);
    secondController.text = _format(durationDateTime.second);

    nameController.text = timer.name;

    return Padding(
      padding: pagePadding,
      child: Form(
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'h',
                      border: OutlineInputBorder(),
                    ),
                    // initialValue: '01',
                    controller: hourController,
                    // onSaved: (name) {
                    //   // TODO
                    // },
                    // onChanged: (String value) {

                    // },
                    onFieldSubmitted: (String value) {
                      final controller = hourController;
                      if (value == '') {
                        controller.text = '00';
                        return;
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        controller.text = '00';
                        return;
                      }
                    },
                    // validator: (String? value) {
                    //   if (value == null || value == '') {
                    //     // return 'fill hours';
                    //     return '';
                    //   }
                    //   final num = int.tryParse(value);
                    //   if (num == null) {
                    //     // return 'fill valid number';
                    //     return '';
                    //   }
                    //   if (num < 0) {
                    //     // return 'fill number greater then 0';
                    //     return '';
                    //   }
                    //   print(num);
                    //   return null;
                    // },
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'm',
                      border: OutlineInputBorder(),
                    ),
                    // initialValue: '02',
                    // onSaved: (name) {
                    // TODO
                    // },
                    controller: minuteController,
                    onFieldSubmitted: (String value) {
                      final controller = minuteController;
                      if (value == '') {
                        controller.text = '00';
                        return;
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        controller.text = '00';
                        return;
                      }
                      if (59 < num) {
                        controller.text = '59';
                        return;
                      }
                    },
                    // validator: (value) {
                    //   if (value == null || value == '') {
                    //     // return 'fill hours';
                    //     return '';
                    //   }
                    //   final num = int.tryParse(value);
                    //   if (num == null) {
                    //     // return 'fill valid number';
                    //     return '';
                    //   }
                    //   if (num < 0 || 59 < num) {
                    //     // return 'fill number greater then 0';
                    //     return '';
                    //   }
                    //   print(num);
                    //   return null;
                    // },
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 's',
                      border: OutlineInputBorder(),
                    ),
                    controller: secondController,
                    onFieldSubmitted: (String value) {
                      final controller = secondController;
                      if (value == '') {
                        controller.text = '00';
                        return;
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0) {
                        controller.text = '00';
                        return;
                      }
                      if (59 < num) {
                        controller.text = '59';
                        return;
                      }
                    },
                    // initialValue: '03',
                    // onSaved: (name) {
                    //   // TODO
                    // },
                    // validator: (name) {
                    //   // TODO
                    // },
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            verticalPadding,
            TextFormField(
              decoration: InputDecoration(
                labelText: 'name',
                border: OutlineInputBorder(),
              ),
              // initialValue: 'timer',
              controller: nameController,
              onFieldSubmitted: (String value) {
                final controller = nameController;
                if (value == '') {
                  controller.text = timer.name;
                  return;
                }
              },
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.done,
            ),
            verticalPadding,
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: !isNew,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.delete(timer);
                      Navigator.pop(context);
                    },
                    child: Text('DELETE'),
                  ),
                ),
                ButtonBar(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text;
                        final duration = Duration(
                          hours: int.parse(hourController.text),
                          minutes: int.parse(minuteController.text),
                          seconds: int.parse(secondController.text),
                        );
                        final newTimer =
                            timer.copyWith(duration: duration, name: name);
                        isNew ? cubit.create(newTimer) : cubit.update(newTimer);
                        Navigator.pop(context);
                      },
                      child: Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
            // ButtonBar(
            //   children: [
            //     // ElevatedButton(
            //     //   child: Text('start'),
            //     //   onPressed: () {
            //     //     // TODO
            //     //   },
            //     // ),
            //     if (isNew) ...[
            //       ElevatedButton(
            //         child: Text('cancel'),
            //         onPressed: () {
            //           // TODO
            //         },
            //       ),
            //       ElevatedButton(
            //         child: Text('create'),
            //         onPressed: () {
            //           // TODO
            //         },
            //       ),
            //     ] else
            //       ElevatedButton(
            //         child: Text('update'),
            //         onPressed: () {
            //           // TODO
            //         },
            //       )
            //   ],
            // ),
            // if (!isNew) ...[
            //   Divider(),
            //   ElevatedButton(
            //     child: Text('delete'),
            //     onPressed: () {
            //       // TODO
            //     },
            //   ),
            // ]
          ],
        ),
      ),
    );
  }
}

enum SettingsCubitError {
  load,
  updateLocale,
}

extension SettingsCubitErrorLocalizations on SettingsCubitError {
  String tr(AppLocalizations l10n) {
    switch (this) {
      case SettingsCubitError.load:
        return l10n.settingsLoadError;
      case SettingsCubitError.updateLocale:
        return l10n.updateLocaleError;
    }
  }
}

class SettingsCubitState extends Equatable {
  final Settings? settings;
  final SettingsCubitError? error;

  SettingsCubitState({
    this.settings,
    this.error,
  });

  @override
  List<Object?> get props => [settings, error];

  SettingsCubitState copyWith({
    Settings? settings,
    SettingsCubitError? error,
  }) {
    return SettingsCubitState(
      settings: settings ?? this.settings,
      error: error ?? this.error,
    );
  }
}

class SettingsCubit extends Cubit<SettingsCubitState> {
  SettingsCubit(this.settingsRepo) : super(SettingsCubitState());

  // Future<List<Timer>>? _timers;
  final SettingsRepo settingsRepo;
  static final _log = Logger('SettingsCubit');

  void _handleError(Exception e, SettingsCubitError error) {
    _log.error('', e);
    emit(state.copyWith(error: error)); // set error, keep the previous timers
  }

  // void increment() => emit(state + 1);
  // void decrement() => emit(state - 1);
  Future<void> load() async {
    try {
      final settings = await settingsRepo.get();
      emit(SettingsCubitState(settings: settings));
    } on Exception catch (e) {
      _handleError(e, SettingsCubitError.load);
    }
  }

  Future<void> updateLocale(Locale locale) async {
    _log.info('update');

    try {
      {
        final settings = (await settingsRepo.get()) ?? Settings(locale: locale);
        await settingsRepo.update(settings.copyWith(locale: locale));
      }
      final settings = await settingsRepo.get();
      emit(SettingsCubitState(settings: settings));
    } on Exception catch (e) {
      _handleError(e, SettingsCubitError.updateLocale);
    }
  }
}

class SettingsView extends StatelessWidget {
  static const String routeName = '/settings';

  SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Padding(padding: pagePadding, child: SettingsForm()),
    );
  }
}

class SettingsForm extends StatelessWidget {
  // final settingsProvider = locator<SettingsProvider>();
  // final navigationService = locator<NavigationService>();
  // static final _localeController = EditingController<Locale>(Locale('_'));

  SettingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // _localeController.value = settings.locale;
    final cubit = context.watch<SettingsCubit>();

    if (cubit.state.error != null) {
      // return Text(cubit.state.error!.tr(AppLocalizations.of(context)!));
      showErrorSnackBar(
        context,
        cubit.state.error!.tr(AppLocalizations.of(context)!),
      );
    }
    // if (cubit.state.settings == null) {
    // return Center(child: CircularProgressIndicator());
    // }

    return Form(
      child: ListView(
        children: [
          // SizedBox(height: 10),
          // ControlledSelectFormField<Locale>(
          //   labelText: l10n.languageLabel,
          //   controller: _localeController,
          //   values: supportedLocales(),
          //   onChange: (Locale locale) {
          //     unawaited(settingsProvider.updateLocale(locale));
          //   },
          // ),

          //  for (final locale in AppLocalizations.supportedLocales)
          //   RadioListTile<Locale>(
          //     title: Text(locale.toString()),
          //     value: locale,
          //     groupValue: Localizations.localeOf(context),
          //     onChanged: (newValue) {
          //       if (newValue == null) {
          //         return;
          //       }
          //     //   controller.value = newValue;
          //     //   onChange?.call(controller.value);

          //     //   Navigator.pop(context);
          //     },
          //   )

          DropdownButtonFormField<Locale>(
            items: [
              for (final locale in AppLocalizations.supportedLocales)
                DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(locale.toString()),
                ),
            ],
            value: Localizations.localeOf(context),
            onChanged: (Locale? newLocale) {
              if (newLocale == null) {
                return;
              }
              cubit.updateLocale(newLocale);
            },
            decoration: InputDecoration(
              labelText: l10n.languageLabel,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
