import 'package:shared_preferences/shared_preferences.dart';

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
