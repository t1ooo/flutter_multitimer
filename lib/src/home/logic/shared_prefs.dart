import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
