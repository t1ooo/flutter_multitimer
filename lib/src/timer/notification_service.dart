import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:equatable/equatable.dart';

import '../logging/logging.dart';

class Notification extends Equatable {
  const Notification(this.id, this.title, this.body);

  final int id;
  final String title;
  final String body;

  @override
  List<Object?> get props => [id, title, body];
}

class NotificationAction {
  NotificationAction(this.key, this.label);

  final String key;
  final String label;
}

abstract class NotificationService {
  Future<void> sendDelayed(
    Notification notification,
    Duration delay, [
    List<NotificationAction>? actions,
  ]);
  Future<void> cancel(int id);
  Future<void> dismiss(int id);
  Future<void> dispose();
}

class TimerNotificationService implements NotificationService {
  static final _log = Logger('NotificationService');
  final _timers = <int, Timer>{};

  @override
  Future<void> sendDelayed(
    Notification notification,
    Duration delay, [
    List<NotificationAction>? actions,
  ]) async {
    _log.info('register: $notification');
    final timer = Timer(delay, () => _log.info('fire: $notification'));
    _timers[notification.id] = timer;
  }

  @override
  Future<void> cancel(int id) async {
    _log.info('cancel: $id');
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  @override
  Future<void> dismiss(int id) async {
    return;
  }

  @override
  Future<void> dispose() async {
    return;
  }
}



class AwesomeNotificationService implements NotificationService {
  AwesomeNotificationService._({
    required this.key,
    required this.name,
    required this.description,
  });

  final String key;
  final String name;
  final String description;
  static final _log = Logger('AwesomeNotificationService');

  @override
  Future<void> dispose() async {
    AwesomeNotifications().dispose();
  }

  static Future<AwesomeNotificationService> create({
    required String key,
    required String name,
    required String description,
    bool updateChannel = false,
  }) async {
    final notificationChannel = NotificationChannel(
      channelKey: key,
      channelName: name,
      channelDescription: description,
      importance: NotificationImportance.Max,
      playSound: false,
      defaultPrivacy: NotificationPrivacy.Public,
    );

    await AwesomeNotifications().initialize(null, []);
    if (updateChannel) {
      await AwesomeNotifications().removeChannel(key);
    }
    await AwesomeNotifications().setChannel(
      notificationChannel,
    );
    return AwesomeNotificationService._(
      key: key,
      name: name,
      description: description,
    );
  }

  @override
  Future<void> cancel(int id) async {
    _log.info('cancel: $id');
    await AwesomeNotifications().cancel(id);
  }

  @override
  Future<void> dismiss(int id) async {
    _log.info('dismiss: $id');
    await AwesomeNotifications().dismiss(id);
  }

  @override
  Future<void> sendDelayed(
    Notification notification,
    Duration delay, [
    List<NotificationAction>? actions,
  ]) async {
    _log.info('sendDelayed: $notification, $delay');
    final localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notification.id,
        channelKey: key,
        title: notification.title,
        body: notification.body,
        wakeUpScreen: true,
        fullScreenIntent: true,
        category: NotificationCategory.Alarm,
      ),
      schedule: NotificationInterval(
        interval: delay.inSeconds,
        timeZone: localTimeZone,
        preciseAlarm: true,
      ),
      actionButtons: actions?.map(_notificationActionButton).toList(),
    );
  }

  static NotificationActionButton _notificationActionButton(
    NotificationAction action,
  ) {
    return NotificationActionButton(
      key: action.key,
      label: action.label,
      autoDismissible: true,
      showInCompactView: true,
      buttonType: ActionButtonType.KeepOnTop,
    );
  }
}
