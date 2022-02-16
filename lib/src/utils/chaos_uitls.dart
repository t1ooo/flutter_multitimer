/// Chaos engineering is the discipline of experimenting on a software system in production in order to build confidence in the system's capability to withstand turbulent and unexpected conditions.
/// source: https://en.wikipedia.org/wiki/Chaos_engineering

import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

const kRandomExceptionProbability = 50;
const kRandomDelayMin = Duration(milliseconds: 1000);
const kRandomDelayMax = Duration(milliseconds: 1000);

final _chaosLog = Logger('chaos');

/// randomly throw Exception with given probability to ensure proper error handling at the user interface level
void randomException([int probability = kRandomExceptionProbability]) {
  if (kDebugMode) {
    if (probability < 0 || 100 < probability) {
      throw RangeError('probability should be between 0 and 100 inclusive');
    }
    final random = Random().nextInt(100);
    if (random < probability) {
      _chaosLog.info('throw exception with probability: $probability');
      throw Exception('random exception');
    }
  }
}

/// randomly add a sync delay to the call to ensure that long operations are properly handled
void randomDelay([
  Duration min = kRandomDelayMin,
  Duration max = kRandomDelayMax,
]) {
  if (kDebugMode) {
    final delay = Duration(
      microseconds: _randomRange(min.inMicroseconds, max.inMicroseconds),
    );
    _chaosLog.info('random sync delay: $delay');
    sleep(delay);
  }
}

/// randomly add a async delay to the call to ensure that long operations are properly handled
Future<void> asyncRandomDelay([
  Duration min = kRandomDelayMin,
  Duration max = kRandomDelayMax,
]) async {
  if (kDebugMode) {
    final delay = Duration(
      microseconds: _randomRange(min.inMicroseconds, max.inMicroseconds),
    );
    _chaosLog.info('random async delay: $delay');
    return Future.delayed(delay, null);
  }
}

int _randomRange(int min, int max) {
  if (max < min) {
    throw ArgumentError('min should be <= max');
  }
  return Random().nextInt(max - min + 1) + min;
}
