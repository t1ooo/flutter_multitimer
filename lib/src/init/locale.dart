import 'dart:ui';

import 'package:flutter/widgets.dart' show Locale, basicLocaleListResolution;

List<Locale> _systemLocales() {
  // return WidgetsBinding.instance!.window.locales;
  return PlatformDispatcher.instance.locales;
}

List<Locale>? _envLocales() {
  // ignore: do_not_use_environment
  const envLocale = String.fromEnvironment('FLUTTER_APP_LOCALE');
  return envLocale.isEmpty ? null : [Locale(envLocale)];
}

Locale detectLocale(Iterable<Locale> supportedLocales) {
  return basicLocaleListResolution(
    _envLocales() ?? _systemLocales(),
    supportedLocales,
  );
}
