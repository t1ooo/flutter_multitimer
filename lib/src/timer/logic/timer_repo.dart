import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../logging/logging.dart';

import 'timer.dart';

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
