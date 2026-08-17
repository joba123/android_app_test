import 'dart:io';

import 'package:einstellungstest_trainer/models/reminder_settings.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Erinnerungen über `flutter_local_notifications`.
///
/// Der Kanal ist bewusst einer: Die App verschickt genau eine Art von
/// Benachrichtigung. Mehrere Kanäle wären für den Nutzer nur eine längere
/// Liste in den Systemeinstellungen.
class LocalReminderService implements ReminderService {
  LocalReminderService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'exam_reminders';
  static const String _channelName = 'Erinnerungen zum Testtermin';
  static const String _channelDescription =
      'Erinnert dich einige Tage vor deinem Einstellungstest ans Üben.';

  bool _ready = false;

  @override
  bool get isAvailable => Platform.isAndroid || Platform.isIOS;

  /// Richtet Plugin und Zeitzonen-Datenbank ein.
  ///
  /// Wird beim ersten Zugriff nachgeholt, damit der App-Start nicht auf das
  /// Laden der Zeitzonen wartet – gebraucht wird beides erst, wenn wirklich
  /// eine Erinnerung geplant wird.
  Future<bool> _ensureReady() async {
    if (_ready) return true;
    if (!isAvailable) return false;

    tz_data.initializeTimeZones();
    // Ohne die Zone des Geräts läge alles in UTC – im Sommer also eine Stunde
    // daneben, auf Reisen mehr.
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Die Berechtigung wird bewusst erst erfragt, wenn der Nutzer die
          // Erinnerungen einschaltet – nicht beim ersten App-Start.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    _ready = true;
    return true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  @override
  Future<PermissionOutcome> requestPermission() async {
    if (!await _ensureReady()) return PermissionOutcome.unsupported;

    final granted = Platform.isAndroid
        ? await _android?.requestNotificationsPermission()
        : await _ios?.requestPermissions(alert: true, badge: true, sound: true);

    return (granted ?? false)
        ? PermissionOutcome.granted
        : PermissionOutcome.denied;
  }

  @override
  Future<bool> hasPermission() async {
    if (!await _ensureReady()) return false;
    if (!Platform.isAndroid) return true;

    return await _android?.areNotificationsEnabled() ?? false;
  }

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {
    if (!await _ensureReady()) return;

    await cancelAll();

    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        tz.TZDateTime.from(reminder.when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Bewusst ungenau: Ein exakter Alarm braucht seit Android 13 die
        // Sonderberechtigung SCHEDULE_EXACT_ALARM, die Google nur für
        // Wecker- und Kalender-Apps freigibt. Für eine Erinnerung am Abend
        // sind ein paar Minuten Abweichung ohne Belang.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    if (!await _ensureReady()) return;
    await _plugin.cancelAll();
  }

  @override
  Future<List<int>> pendingIds() async {
    if (!await _ensureReady()) return const [];

    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((request) => request.id).toList();
  }
}
