import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timer.g.dart';

enum TimerStatus {
  // ready,
  start,
  stop,
  pause,
  // resume,
}

@JsonSerializable()
class Timer extends Equatable {
  Timer({
    required this.id,
    required this.name,
    required this.duration,
    required this.rest,
    required this.status,
    required this.lastUpdate,
    required this.startedAt,
  }) {
    if (id < 0) {
      throw Exception('id should be >= 0');
    }
    if (duration < Duration.zero) {
      throw Exception('duration should be >= 0');
    }
    if (rest < Duration.zero) {
      throw Exception('rest should be >= 0');
    }
  }

  Timer.initial({
    required this.id,
    required this.name,
    required this.duration,
    required this.status,
    required DateTime now,
    // required this.lastUpdate,
    // required this.startedAt,
  })  : rest = duration,
        lastUpdate = now,
        startedAt = now;

  final int id;
  final String name;
  final Duration duration;
  final Duration rest; // rest of duration
  final TimerStatus status;
  final DateTime lastUpdate;
  final DateTime startedAt;

  Timer start(DateTime now) {
    return copyWith(
      status: TimerStatus.start,
      startedAt: now,
      rest: duration,
    );
  }

  Timer resume(DateTime now) {
    return copyWith(
      status: TimerStatus.start,
      startedAt: now,
      rest: countdown(now),
    );
  }

  Timer stop() {
    return copyWith(
      status: TimerStatus.stop,
      rest: duration,
    );
  }

  Timer pause(DateTime now) {
    return copyWith(
      status: TimerStatus.pause,
      rest: countdown(now),
    );
  }

  Duration countdown(DateTime now) {
    if (status == TimerStatus.start /* || status == TimerStatus.pause */) {
      final stopAt = startedAt.add(rest);
      final countdown = stopAt.difference(now);
      // print('$rest, $countdown');
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

  factory Timer.fromJson(Map<String, dynamic> json) => _$TimerFromJson(json);

  Map<String, dynamic> toJson() => _$TimerToJson(this);
}

// TODO: MAYBE: move to Timer
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
