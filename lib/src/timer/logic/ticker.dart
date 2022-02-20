class Ticker {
  const Ticker();
  Stream<Duration> tickCountdown(Duration duration) {
    final ticks = duration.inSeconds;
    return Stream.periodic(
      Duration(seconds: 1),
      (x) => Duration(seconds: ticks - x - 1),
    ).take(ticks);
  }

  Stream<Duration> tick() {
    return Stream.periodic(
      Duration(seconds: 1),
      (x) => Duration(seconds: x),
    );
  }
}
