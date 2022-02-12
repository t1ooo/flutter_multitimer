import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class Timer {
  final String id;
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

  Timer copyWith({
    String? id,
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
}

class TimersCubitState {
  final List<Timer>? timers;
  final Object? error;

  TimersCubitState({
    this.timers,
    this.error,
  });
}

class TimersCubit extends Cubit<TimersCubitState> {
  TimersCubit() : super(TimersCubitState());

  // void increment() => emit(state + 1);
  // void decrement() => emit(state - 1);
  Future<void> load() async {
    await Future.delayed(Duration(milliseconds: 500), null);
    emit(TimersCubitState(timers: [
      Timer(
        id: 'a',
        name: 'stop',
        duration: Duration(minutes: 5),
        countdown: Duration(seconds: 60 * 60 * 2),
        status: TimerStatus.stop,
      ),
      Timer(
        id: 'b',
        name: 'start',
        duration: Duration(minutes: 5),
        countdown: Duration(seconds: 125),
        status: TimerStatus.start,
      ),
      Timer(
        id: 'c',
        name: 'pause',
        duration: Duration(minutes: 5),
        countdown: Duration(seconds: 35),
        status: TimerStatus.pause,
      ),
    ]));
  }

  Future<void> create(Timer timer) async {}
  Future<void> update(Timer timer) async {}
  Future<void> delete(Timer timer) async {}

  Future<void> start(Timer timer) async {}
  Future<void> stop(Timer timer) async {}
  Future<void> pause(Timer timer) async {}
  Future<void> resume(Timer timer) async {}
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
  TimerCubit(Timer timer, [this.ticker = const Ticker()])
      : super(TimerCubitState(timer: timer)) {
    if (timer.status == TimerStatus.start) {
      start();
    }
  }

  final Ticker ticker;
  StreamSubscription<Duration>? _tickerSub;

  Future<void> start() async {
    emit(TimerCubitState(timer: state.timer.copyWith(status: TimerStatus.start)
        /* start.timerItem,
      TimerStatus.busy,
      start.timerItem.duration, */
        ));
    await _tickerSub?.cancel();
    _tickerSub =
        ticker.tick(state.timer.duration).listen((duration) => _tick(duration));
  }

  Future<void> stop() async {
    emit(
      TimerCubitState(
        timer: state.timer
            .copyWith(status: TimerStatus.stop, countdown: state.timer.duration),
      ),
    );
    await _tickerSub?.cancel();
  }

  Future<void> pause() async {
    emit(
      TimerCubitState(
        timer: state.timer.copyWith(status: TimerStatus.pause),
      ),
    );
    _tickerSub?.pause();
  }

  Future<void> resume() async {
    emit(
      TimerCubitState(
        timer: state.timer.copyWith(status: TimerStatus.start),
      ),
    );
    _tickerSub?.resume();
  }

  Future<void> _tick(Duration duration) async {
    if (duration.inSeconds > 0) {
      emit(TimerCubitState(timer: state.timer.copyWith(countdown: duration)));
    } else {
      // emit(TimerCubitState(
      //     timer: state.timer
      //         .copyWith(status: TimerStatus.stop, countdown: duration)));
      // await _tickerSub?.cancel();
      stop();
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

const pagePadding = EdgeInsets.all(20);
// const pagePadding = EdgeInsets.symmetric(vertical: 20, horizontal: 20);

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
      body: BlocProvider(
        create: (_) => TimersCubit()..load(),
        child: TimerList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TimerEditView(isNew: true)),
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

    return Column(
      // direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final timer in cubit.state.timers!)
          BlocProvider(
            create: (_) => TimerCubit(timer),
            child: TimerListItem(),
          ),
      ],
    );
  }
}

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

    const iconSize = 45.0;
    final dateFormat = DateFormat('HH:mm:ss');
    // timer.countdown.inSeconds
    final fmtCountdown = dateFormat.format(dateTime(
      hour: timer.countdown.inSeconds ~/ (60 * 60),
      minute: timer.countdown.inSeconds ~/ 60,
      second: timer.countdown.inSeconds % 60,
    ));

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
                    Text(timer.name),
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
          MaterialPageRoute(builder: (_) => TimerEditView()),
        );
      },
    );
  }
}

class TimerEditView extends StatelessWidget {
  TimerEditView({Key? key, this.isNew = false}) : super(key: key);

  bool isNew;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timer'),
      ),
      body: TimerEdit(isNew: isNew),
    );
  }
}

class TimerEdit extends StatelessWidget {
  TimerEdit({Key? key, this.isNew = false}) : super(key: key);

  bool isNew;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = SizedBox(height: 30);

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
                    initialValue: '01',
                    onSaved: (name) {
                      // TODO
                    },
                    validator: (name) {
                      // TODO
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    initialValue: '02',
                    onSaved: (name) {
                      // TODO
                    },
                    validator: (name) {
                      // TODO
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    initialValue: '03',
                    onSaved: (name) {
                      // TODO
                    },
                    validator: (name) {
                      // TODO
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
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
              initialValue: 'timer',
              onSaved: (name) {
                // TODO
              },
              validator: (name) {
                // TODO
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            verticalPadding,
            verticalPadding,
            ButtonBar(
              children: [
                if (isNew)
                  ElevatedButton(
                    child: Text('create'),
                    onPressed: () {
                      // TODO
                    },
                  )
                else
                  ElevatedButton(
                    child: Text('delete'),
                    onPressed: () {
                      // TODO
                    },
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
