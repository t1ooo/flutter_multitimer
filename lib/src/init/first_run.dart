import 'package:shared_preferences/shared_preferences.dart';

const _key = '_is_first_run';

class FirstRun {
  FirstRun._(this._isFirstRun);

  bool _isFirstRun;

  bool get isFirstRun => _isFirstRun;

  static Future<FirstRun> create() async {
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

Future<bool> firstRun() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(_key)) {
    return false;
  }

  await prefs.setBool(_key, true);
  return true;
}
