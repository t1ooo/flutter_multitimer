import 'dart:ui' show Locale;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../l10n/gen/app_localizations.dart';
import '../logging/logging.dart';
import 'settings.dart';
import 'settings_repo.dart';

enum SettingsCubitError {
  load,
  updateLocale,
}

extension SettingsCubitErrorLocalizations on SettingsCubitError {
  String tr(AppLocalizations l10n) {
    switch (this) {
      case SettingsCubitError.load:
        return l10n.settingsLoadError;
      case SettingsCubitError.updateLocale:
        return l10n.updateLocaleError;
    }
  }
}

class SettingsCubitState extends Equatable {
  const SettingsCubitState({
    this.settings,
    this.error,
  });

  final Settings? settings;
  final SettingsCubitError? error;

  @override
  List<Object?> get props => [settings, error];

  SettingsCubitState copyWith({
    Settings? settings,
    SettingsCubitError? error,
  }) {
    return SettingsCubitState(
      settings: settings ?? this.settings,
      error: error ?? this.error,
    );
  }
}

class SettingsCubit extends Cubit<SettingsCubitState> {
  SettingsCubit(this.settingsRepo) : super(SettingsCubitState());

  final SettingsRepo settingsRepo;
  static final _log = Logger('SettingsCubit');

  void _handleError(Exception e, SettingsCubitError error) {
    _log.error('', e);
    emit(state.copyWith(error: error)); // set error, keep the previous timers
  }

  Future<void> load() async {
    try {
      final settings = await settingsRepo.get();
      emit(SettingsCubitState(settings: settings));
    } on Exception catch (e) {
      _handleError(e, SettingsCubitError.load);
    }
  }

  Future<void> updateLocale(Locale locale) async {
    _log.info('update');
    try {
      {
        final settings = (await settingsRepo.get()) ?? Settings(locale: locale);
        await settingsRepo.update(settings.copyWith(locale: locale));
      }
      final settings = await settingsRepo.get();
      emit(SettingsCubitState(settings: settings));
    } on Exception catch (e) {
      _handleError(e, SettingsCubitError.updateLocale);
    }
  }
}
