// TODO: nullable Settings.locale, add init to Repo

import 'dart:async' as async;
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/gen/app_localizations.dart';
import 'settings.dart';
import 'settings_repository.dart';
import 'timer.dart';
import 'ui_utils.dart';
import 'utils/chaos_uitls.dart';

Future<void> clearSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

class FirstRun {
  FirstRun._(this._isFirstRun);

  static const _key = '_is_first_run';
  bool _isFirstRun;

  bool get isFirstRun => _isFirstRun;

  static Future<FirstRun> init() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_key)) {
      return FirstRun._(false);
    }

    await prefs.setBool(_key, true);
    return FirstRun._(true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _isFirstRun = true;
  }
}

extension LoggerExt on Logger {
  void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    severe(message, error, stackTrace);
  }
}

class Notification extends Equatable {
  const Notification(this.id, this.title, this.body);

  final int id;
  final String title;
  final String body;

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
}

class NotificationLocalizations {
  NotificationLocalizations(this.l10n);

  factory NotificationLocalizations.of(BuildContext context) {
    return NotificationLocalizations(AppLocalizations.of(context)!);
  }

  final AppLocalizations l10n;

  String get notificationBody => l10n.notificationBody;
  String get stopSignalButton => l10n.stopSignalButton;
}

class NotificationAction {
  NotificationAction(this.key, this.label);

  final String key;
  final String label;
}

class AwesomeNotificationService implements NotificationService {
  AwesomeNotificationService._({
    required this.key,
    required this.name,
    required this.description,
  });

  final String key;
  final String name;
  final String description;
  static final _log = Logger('AwesomeNotificationService');

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
    );
    return AwesomeNotificationService._(
      key: key,
      name: name,
      description: description,
    );
  }

  @override
  async.Future<void> cancel(int id) async {
    _log.info('cancel: $id');
    await AwesomeNotifications().cancel(id);
  }

  @override
  async.Future<void> dismiss(int id) async {
    _log.info('dismiss: $id');
    await AwesomeNotifications().dismiss(id);
  }

  @override
  async.Future<void> sendDelayed(
    Notification notification,
    Duration delay, [
    List<NotificationAction>? actions,
  ]) async {
    _log.info('sendDelayed: $notification, $delay');
    final localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();
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
      ),
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

abstract class TimerRepo {
  Future<List<Timer>> list();
  Future<Timer> create(Timer timer);
  Future<void> update(Timer timer);
  Future<void> delete(Timer timer);
}

class InMemoryTimerRepo implements TimerRepo {
  static final _log = Logger('InMemoryTimerRepo');
  final _timers = <int, Timer>{};

  @override
  Future<List<Timer>> list() async {
    return _timers.values.toList();
  }

  @override
  Future<Timer> create(Timer timer) async {
    _log.info('create: $timer');
    final id = _genId();
    final timerWithId = timer.copyWith(id: id);
    _log.info('create: $timerWithId');
    _timers[id] = timerWithId;
    return timerWithId;
  }

  @override
  Future<void> update(Timer timer) async {
    _log.info('update: $timer');
    if (!_timers.containsKey(timer.id)) {
      throw Exception('not found');
    }
    _timers[timer.id] = timer;
  }

  @override
  Future<void> delete(Timer timer) async {
    _log.info('delete: $timer');
    _timers.remove(timer.id);
  }

  int _id = 0;
  int _genId() {
    _id++;
    return _id;
  }
}

class SharedPrefsTimerRepo implements TimerRepo {
  static const _timerKeyPrefix = 'timer_item';
  static const _counterKey = 'timer_counter';

  @override
  Future<Timer> create(Timer timer) async {
    final sharedPrefs = await SharedPreferences.getInstance();

    final counter = (sharedPrefs.getInt(_counterKey) ?? 0) + 1;
    await sharedPrefs.setInt(_counterKey, counter);

    final timerWithId = timer.copyWith(id: counter);
    await sharedPrefs.setString(
      _timerKey(timer.id),
      jsonEncode(timer.toJson()),
    );

    return timerWithId;
  }

  @override
  Future<List<Timer>> list() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    return sharedPrefs.getKeys().where((key) {
      return key.startsWith(_timerKeyPrefix);
    }).map(
      (key) {
        return Timer.fromJson(
          // TODO: util mapJromJson
          jsonDecode(sharedPrefs.getString(key)!) as Map<String, dynamic>,
        );
      },
    ).toList()
      ..sort((a, b) => a.id - b.id);
  }

  @override
  Future<void> delete(Timer timer) async {
    final sharedPrefs = await SharedPreferences.getInstance();

    await sharedPrefs.remove(_timerKey(timer.id));
  }

  @override
  Future<void> update(Timer timer) async {
    final sharedPrefs = await SharedPreferences.getInstance();

    await sharedPrefs.setString(
      _timerKey(timer.id),
      jsonEncode(timer.toJson()),
    );
  }

  String _timerKey(int id) {
    return '$_timerKeyPrefix$id';
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

  final NotificationService notificationService;

  final TimerRepo timerRepo;
  final Clock clock;
  final Ticker ticker;
  async.StreamSubscription<Duration>? _tickerSub;
  NotificationLocalizations l10n;
  static final _log = Logger('TimerCubit');
  // static const notificationId = 0;

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

  @override
  Future<void> close() {
    _log.info('close: ${state.timer}');
    _tickerSub?.cancel();
    notificationService.cancel(state.timer.id);
    return super.close();
  }

  Future<void> start() async {
    final timer = state.timer.start(clock.now());
    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();
    _tickerSub = ticker.tick(state.timer.duration).listen(_tick);

    async.unawaited(_sendNotification(timer));
    async.unawaited(_updateTimer(timer));
  }

  Future<void> _resumeStarted() async {
    final timer = state.timer.resume(clock.now());
    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();
    _tickerSub = ticker.tick(state.timer.duration).listen(_tick);

    // no need to send a notification because we already sent a delayed notification when we started the timer

    async.unawaited(_updateTimer(timer));
  }

  Future<void> stop() async {
    async.unawaited(_done());
    async.unawaited(notificationService.cancel(state.timer.id));
  }

  Future<void> _done() async {
    final timer = state.timer.stop();

    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();

    async.unawaited(_updateTimer(timer));
  }

  Future<void> pause() async {
    final timer = state.timer.pause(clock.now());
    emit(TimerCubitState(timer: timer));

    _tickerSub?.pause();

    async.unawaited(notificationService.cancel(timer.id));

    async.unawaited(_updateTimer(timer));
  }

  Future<void> resume() async {
    final timer = state.timer.resume(clock.now());
    emit(TimerCubitState(timer: timer));

    _tickerSub?.resume();

    async.unawaited(_sendNotification(timer));

    async.unawaited(_updateTimer(timer));
  }

  Future<void> _tick(Duration countdown) async {
    if (state.timer.countdown(clock.now()) < Duration.zero) {
      final timer = state.timer.copyWith();
      emit(TimerCubitState(timer: timer));
      await async.Future.delayed(Duration(seconds: 1));
      async.unawaited(_done());
      return;
    }

    final timer = state.timer.copyWith();
    emit(TimerCubitState(timer: timer));
  }

  Future<void> _sendNotification(Timer timer) async {
    await notificationService.cancel(state.timer.id);
    // TODO: MAYBE: add method NotificationService.sendAt(Notification, DataTime)
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

  void setLocalizations(NotificationLocalizations l10n) {
    // print('setLocalizations');
    this.l10n = l10n;
  }

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

// UI --------------------------------------

final dateFormat = DateFormat('HH:mm:ss');

DateTime dateTimeFromDuration(Duration duration) {
  return dateTime(
    hour: duration.inSeconds ~/ (60 * 60 * 24),
    minute: duration.inSeconds ~/ 60,
    second: duration.inSeconds % 60,
  );
}

String formatCountdown(Duration countdown) {
  final inSeconds =
      (countdown.inMicroseconds / Duration.microsecondsPerSecond).round();
  final dTimer = dateTime(
    hour: inSeconds ~/ (60 * 60 * 24),
    minute: inSeconds ~/ 60,
    second: inSeconds % 60,
  );
  return dateFormat.format(dTimer);
}

class HomeView extends StatelessWidget {
  const HomeView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timers'),
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
              builder: (_) => TimerEditView(timer: draftTimer(), isNew: true),
            ),
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
    final fmtCountdown = formatCountdown(countdown);
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

class TimerEditView extends StatelessWidget {
  const TimerEditView({Key? key, required this.timer, this.isNew = false})
      : super(key: key);

  final bool isNew;
  final Timer timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timer'),
      ),
      body: Padding(
        padding: pagePadding,
        child: TimerEdit(timer: timer, isNew: isNew),
      ),
    );
  }
}

class TimerEdit extends StatelessWidget {
  const TimerEdit({Key? key, required this.timer, this.isNew = false})
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

    return Form(
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
                  controller: hourController,
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
            controller: nameController,
            onFieldSubmitted: (String value) {
              final controller = nameController;
              if (value == '') {
                controller.text = timer.name;
                return;
              }
            },
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
        ],
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
  const SettingsCubitState({
    this.settings,
    this.error,
  });

  final Settings? settings;
  final SettingsCubitError? error;

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

  final SettingsRepo settingsRepo;
  static final _log = Logger('SettingsCubit');

  void _handleError(Exception e, SettingsCubitError error) {
    _log.error('', e);
    emit(state.copyWith(error: error)); // set error, keep the previous timers
  }

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
  const SettingsView({Key? key}) : super(key: key);

  static const String routeName = '/settings';

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
  const SettingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // _localeController.value = settings.locale;
    final cubit = context.watch<SettingsCubit>();

    if (cubit.state.error != null) {
      showErrorSnackBar(
        context,
        cubit.state.error!.tr(AppLocalizations.of(context)!),
      );
    }

    return Form(
      child: ListView(
        children: [
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
