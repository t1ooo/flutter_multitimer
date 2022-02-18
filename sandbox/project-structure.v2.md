model
    class Ticker
    class Timer
        Timer draftTimer
    class Settings
        class LocaleJsonConverter
bloc
    class SettingsCubit
        class SettingsCubitState
        extension SettingsCubitErrorLocalizations on SettingsCubitError
    class TimerCubit
        class TimerCubitState
        extension TimerCubitErrorLocalizations on TimerCubitError     
    class TimersCubit
        class TimersCubitState
        extension TimersCubitErrorLocalizations on TimersCubitError
ui
    class HomeView
        class TimerList
        class TimerListItem
            String formatCountdown
    class SettingsView
        class SettingsForm
    class TimerEditView
        class TimerEdit
            DateTime dateTimeFromDuration
service
    abstract class NotificationService
        class AwesomeNotificationService
        class TimerNotificationService
        class Notification
        class NotificationAction
        class NotificationLocalizations
    class FirstRun
    abstract class AppLocalizations
        class AppLocalizationsEn
        class AppLocalizationsRu
    extension LoggerExt on Logger
repo
    abstract class SettingsRepo
        class InMemorySettingsRepo
        class SharedPrefsSettingsRepo
    abstract class TimerRepo
        class InMemoryTimerRepo
        class SharedPrefsTimerRepo
util
    dateTime
        DateTime dateTime
    chaos
        Future<void> asyncRandomDelay
        void randomDelay
        void randomException
    SharedPreferences
        Future<void> clearSharedPreferences
    SnackBar
        void showErrorSnackBar
    debug
        Widget whenDebug

init
    Future<NotificationService> notificationService
    Future<SettingsRepo> settingsRepo
    Future<TimerRepo> timerRepo
    List<Timer> initialTimers
    void configureLogger


class MyApp
