
settings
    repo
        abstract class SettingsRepo
            class InMemorySettingsRepo
            class SharedPrefsSettingsRepo
    model
        class Settings
            class LocaleJsonConverter
    bloc
        class SettingsCubit
            class SettingsCubitState
    ui
        class SettingsView
            class SettingsForm


timer
    repo
        abstract class TimerRepo
            class InMemoryTimerRepo
            class SharedPrefsTimerRepo
    model
        class Timer
        class Ticker
    bloc
        class TimerCubit
            class TimerCubitState
        class TimersCubit
            class TimersCubitState
    ui
        class TimerEditView
            class TimerEdit
        class TimerList
        class TimerListItem
        class TimerCreateButton
    service
        abstract class NotificationService
            class AwesomeNotificationService
            class Notification
            class NotificationAction
            class NotificationLocalizations
            class TimerNotificationService


l10n
    abstract class AppLocalizations
    class AppLocalizationsEn
    class AppLocalizationsRu

logger
    extension LoggerExt on Logger

chaos
    void randomDelay
    void randomException
    Future<void> asyncRandomDelay

home
    ui
        class HomeView

class MyApp


init
    Future<NotificationService> notificationService
    Future<SettingsRepo> settingsRepo
    Future<TimerRepo> timerRepo
    void configureLogger
    FirstRun
        class FirstRun




extension TimersCubitErrorLocalizations on TimersCubitError
extension TimerCubitErrorLocalizations on TimerCubitError
extension SettingsCubitErrorLocalizations on SettingsCubitError



DateTime dateTime
DateTime dateTimeFromDuration
Future<void> clearSharedPreferences
List<Timer> initialTimers
String formatCountdown
Timer draftTimer
void showErrorSnackBar
Widget whenDebug
