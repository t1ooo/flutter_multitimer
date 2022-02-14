// TODO: enable all analysis_options.yaml
// TODO: add l10n
// TODO: add startTime to Timer and check countdown when restart

import 'dart:async' as async;
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

// const dismissNotificationAfter = Duration(seconds: 10);

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
  Future<void> sendDelayed(Notification notification, Duration delay);
  Future<void> cancel(int id);
  Future<void> dismiss(int id);
}

class TimerNotificationService implements NotificationService {
  static final _log = Logger('NotificationService');
  final _timers = <int, async.Timer>{};

  @override
  Future<void> sendDelayed(Notification notification, Duration delay) async {
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
}

class AwesomeNotificationService implements NotificationService {
  final String key;
  final String name;
  final String description;
  final bool updateChannel;
  bool _isReady = false;

  static final log = Logger('AwesomeNotificationService');

  AwesomeNotificationService({
    required this.key,
    required this.name,
    required this.description,
    this.updateChannel = false,
  });

  Future<void> dispose() async {
    AwesomeNotifications().dispose();
  }

  Future<void> _init() async {
    if (_isReady) {
      return;
    }

    final notificationChannel = NotificationChannel(
      channelKey: key,
      channelName: name,
      channelDescription: description,
      importance: NotificationImportance.Max,
      defaultPrivacy: NotificationPrivacy.Public,
      playSound: true,
      // defaultRingtoneType: DefaultRingtoneType.Alarm,
      defaultRingtoneType: DefaultRingtoneType.Notification,
    );

    await AwesomeNotifications().initialize(null, []);
    if (updateChannel) {
      await AwesomeNotifications().removeChannel(key);
    }
    await AwesomeNotifications().setChannel(
      notificationChannel,
      forceUpdate: false,
    );

    _isReady = true;
  }

  // static Future<AwesomeNotificationService> init({
  //   required String key,
  //   required String name,
  //   required String description,
  //   bool updateChannel = false,
  // }) async {
  //   final notificationChannel = NotificationChannel(
  //     channelKey: key,
  //     channelName: name,
  //     channelDescription: description,
  //     importance: NotificationImportance.Max,
  //     playSound: false,
  //     defaultPrivacy: NotificationPrivacy.Public,
  //   );

  //   await AwesomeNotifications().initialize(null, []);
  //   if (updateChannel) {
  //     await AwesomeNotifications().removeChannel(key);
  //   }
  //   await AwesomeNotifications().setChannel(
  //     notificationChannel,
  //     forceUpdate: false,
  //   );
  //   return AwesomeNotificationService._(
  //     key: key,
  //     name: name,
  //     description: description,
  //   );
  // }

  @override
  async.Future<void> cancel(int id) async {
    await _init();
    await AwesomeNotifications().cancel(id);
  }

  @override
  async.Future<void> dismiss(int id) async {
    await _init();
    await AwesomeNotifications().dismiss(id);
  }

  @override
  async.Future<void> sendDelayed(
    Notification notification,
    Duration delay,
  ) async {
    await _init();
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
      actionButtons: [_notificationActionButton('stop', 'STOP SIGNAL')],
    );
  }

  static NotificationActionButton _notificationActionButton(
    String key,
    String label,
  ) =>
      NotificationActionButton(
        key: key,
        label: label,
        autoDismissible: true,
        showInCompactView: true,
        buttonType: ActionButtonType.KeepOnTop,
      );
}

class TimerRepo {
  static final _log = Logger('TimerRepo');

  final Map<int, Timer> _timers = {
    0: Timer(
      id: 0,
      name: 'stop',
      duration: Duration(seconds: 60 * 60 * 2),
      countdown: Duration(seconds: 60 * 60 * 2),
      status: TimerStatus.stop,
    ),
    1: Timer(
      id: 1,
      name: 'start',
      duration: Duration(seconds: 125),
      countdown: Duration(seconds: 125),
      status: TimerStatus.start,
    ),
    2: Timer(
      id: 2,
      name: 'pause',
      duration: Duration(seconds: 5),
      countdown: Duration(seconds: 5),
      status: TimerStatus.pause,
    ),
    3: Timer(
      id: 3,
      name: 'pause',
      duration: Duration(seconds: 10),
      countdown: Duration(seconds: 10),
      status: TimerStatus.pause,
    ),
  };

  Future<List<Timer>> list() async {
    await _delay();
    return _timers.values.toList();
  }

  Future<Timer> create(Timer timer) async {
    // if (_timers.containsKey(timer.id)) {
    //   throw Exception('already exists');
    // }
    final id = _genId();
    final timerWithId = timer.copyWith(id: id);
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

  int _genId() {
    return _timers.length;
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
  final Duration countdown;
  final TimerStatus status;

  Timer({
    required this.id,
    required this.name,
    required this.duration,
    required this.countdown,
    required this.status,
  });

  // Timer.stopped({
  //   required this.id,
  //   required this.name,
  //   required this.duration,
  // })  : countdown = duration,
  //       status = TimerStatus.stop;

  Timer copyWith({
    int? id,
    String? name,
    Duration? duration,
    Duration? countdown,
    TimerStatus? status,
  }) {
    return Timer(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      countdown: countdown ?? this.countdown,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, name, duration, countdown, status];
}

Timer draftTimer() {
  return Timer(
    id: 0,
    name: 'timer',
    duration: Duration(minutes: 5),
    countdown: Duration(minutes: 5),
    status: TimerStatus.stop,
  );
}

class TimersCubitState extends Equatable {
  final List<Timer>? timers;
  final Object? error;

  TimersCubitState({
    this.timers,
    this.error,
  });

  @override
  List<Object?> get props => [timers, error];

  TimersCubitState copyWith({
    List<Timer>? timers,
    Object? error,
  }) {
    return TimersCubitState(
      timers: timers ?? this.timers,
      error: error ?? this.error,
    );
  }
}

class TimersCubit extends Cubit<TimersCubitState> {
  TimersCubit(this.timerRepo) : super(TimersCubitState());

  // Future<List<Timer>>? _timers;
  final TimerRepo timerRepo;
  static final _log = Logger('TimersCubit');

  void _handleError(Exception e, [StackTrace? st]) {
    _log.error('', e, st);
    emit(state.copyWith(error: e)); // set error, keep the previous timers
  }

  // void increment() => emit(state + 1);
  // void decrement() => emit(state - 1);
  Future<void> load() async {
    try {
      final timers = await timerRepo.list();
      emit(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e);
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
    try {
      await timerRepo.create(timer);
      final timers = await timerRepo.list();
      emit(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e);
    }
  }

  Future<void> update(Timer timer) async {
    try {
      await timerRepo.update(timer);
      final timers = await timerRepo.list();
      emit(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e);
    }
  }

  Future<void> delete(Timer timer) async {
    try {
      await timerRepo.delete(timer);
      final timers = await timerRepo.list();
      emit(TimersCubitState(timers: timers));
    } on Exception catch (e) {
      _handleError(e);
    }
  }

  // Future<void> start(Timer timer) async {}
  // Future<void> stop(Timer timer) async {}
  // Future<void> pause(Timer timer) async {}
  // Future<void> resume(Timer timer) async {}
}

class TimerCubitState {
  final Timer timer;
  final Object? error;

  TimerCubitState({
    required this.timer,
    this.error,
  });
}

class TimerCubit extends Cubit<TimerCubitState> {
  TimerCubit(
    Timer timer,
    this.timerRepo,
    this.notificationService, [
    this.saveInterval = const Duration(seconds: 5),
    this.ticker = const Ticker(),
  ]) : super(TimerCubitState(timer: timer)) {
    if (saveInterval < const Duration(seconds: 1)) {
      throw Exception('saveInterval should be >= than 1 second');
    }
    if (timer.status == TimerStatus.start) {
      start();
    }
  }

  final NotificationService notificationService;

  /// delay between saving the current state of the timer to the repository
  final Duration saveInterval;
  final TimerRepo timerRepo;
  final Ticker ticker;
  async.StreamSubscription<Duration>? _tickerSub;
  static final _log = Logger('TimerCubit');
  // static const notificationId = 0;

  @override
  Future<void> close() {
    _log.info('close: ${state.timer}');
    _tickerSub?.cancel();
    // TODO: is it working correctly? maybe should be canceled in TimersCubit
    notificationService.cancel(state.timer.id);
    return super.close();
  }

  Future<void> start() async {
    final timer = state.timer.copyWith(status: TimerStatus.start);
    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();
    _tickerSub = ticker.tick(state.timer.duration).listen(_tick);

    notificationService.sendDelayed(
      Notification(timer.id, timer.name, ''),
      timer.countdown,
    );

    timerRepo.update(timer);
  }

  Future<void> stop() async {
    _done();

    notificationService.cancel(state.timer.id);
  }

  Future<void> _done() async {
    final timer = state.timer.copyWith(
      status: TimerStatus.stop,
      countdown: state.timer.duration,
    );
    emit(TimerCubitState(timer: timer));

    await _tickerSub?.cancel();

    timerRepo.update(timer);
  }

  Future<void> pause() async {
    final timer = state.timer.copyWith(status: TimerStatus.pause);
    emit(TimerCubitState(timer: timer));

    _tickerSub?.pause();

    notificationService.cancel(timer.id);

    timerRepo.update(timer);
  }

  Future<void> resume() async {
    final timer = state.timer.copyWith(status: TimerStatus.start);
    emit(TimerCubitState(timer: timer));

    _tickerSub?.resume();

    notificationService.sendDelayed(
      Notification(timer.id, timer.name, ''),
      timer.countdown,
    );

    timerRepo.update(timer);
  }

  Future<void> _tick(Duration countdown) async {
    if (countdown.inSeconds <= 0) {
      _done();
      return;
    }

    final timer = state.timer.copyWith(countdown: countdown);
    emit(TimerCubitState(timer: timer));

    if (countdown.inSeconds % saveInterval.inSeconds == 0) {
      timerRepo.update(timer);
    }
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

class TimerList extends StatelessWidget {
  TimerList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TimersCubit>();

    if (cubit.state.error != null) {
      return Text(cubit.state.error.toString());
    }
    if (cubit.state.timers == null) {
      return Center(child: CircularProgressIndicator());
    }
    // print('rebuild');
    return Column(
      // direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final timer in cubit.state.timers!)
          BlocProvider(
            key: Key(timer.id.toString()),
            create: (_) => TimerCubit(
              timer,
              context.read<TimerRepo>(),
              context.read<NotificationService>(),
            ),
            child: TimerListItem(/* key: Key(timer.id.toString()) */),
          ),
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

    if (cubit.state.error != null) {
      return Text(cubit.state.error.toString());
    }

    final timer = cubit.state.timer;

    const iconSize = 40.0;
    // timer.countdown.inSeconds
    final fmtCountdown = formatCountdown(timer.countdown);

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
