import 'dart:convert';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
@LocaleJsonConverter()
class Settings extends Equatable {
  final Locale locale;

  Settings({
    required this.locale,
  });

  Settings copyWith({
    Locale? locale,
  }) {
    return Settings(
      locale: locale ?? this.locale,
    );
  }

  @override
  String toString() {
    return 'Settings ${toJson()}';
  }

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  List<Object?> get props => [locale];
}

class LocaleJsonConverter implements JsonConverter<Locale, String> {
  const LocaleJsonConverter();

  @override
  Locale fromJson(String json) {
    return _fromMap(jsonDecode(json));
  }

  @override
  String toJson(Locale object) {
    return jsonEncode(_toMap(object));
  }

  Locale _fromMap(Map<String, dynamic> json) =>
      Locale(json['languageCode'] as String, json['countryCode']);

  Map<String, dynamic> _toMap(Locale object) => {
        'languageCode': object.languageCode,
        'countryCode': object.countryCode,
      };
}
