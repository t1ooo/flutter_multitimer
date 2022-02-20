import 'dart:ui';

import 'package:flutter/widgets.dart' show Locale;

import '../l10n/gen/app_localizations.dart';

Future<AppLocalizations> loadAppLocalizations(Locale locale) {
  return AppLocalizations.delegate.load(locale);
}
