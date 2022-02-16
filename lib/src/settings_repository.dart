import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

abstract class SettingsRepo {
  Future<Settings?> get();
  // Future<Settings> mustGet();
  Future<void> update(Settings alarm);
}

class InmemorySettingsRepo implements SettingsRepo {
  Settings? _settings;

  InmemorySettingsRepo();

  @override
  Future<Settings?> get() async {
    return _settings;
  }

  // @override
  // Future<Settings> mustGet() async {
  //   final settings = await get();
  //   if (settings == null) {
  //     throw Exception('settings not found');
  //   }
  //   return settings;
  // }

  @override
  Future<void> update(Settings settings) async {
    _settings = settings;
  }
}

class SharedPrefsSettingsRepo implements SettingsRepo {
  static const _settingsKey = 'settings_';

  @override
  Future<Settings?> get() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    final data = sharedPreferences.getString(_settingsKey);
    if (data == null) {
      return null;
    }
    return Settings.fromJson(jsonDecode(data));
  }

  // @override
  // Future<Settings> mustGet() async {
  //   final settings = await get();
  //   if (settings == null) {
  //     throw Exception('settings not found');
  //   }
  //   return settings;
  // }

  @override
  Future<void> update(Settings settings) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.setString(
      _settingsKey,
      jsonEncode(settings.toJson()),
    );
  }
}
