import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification Service für lokale Push-Benachrichtigungen
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Plugin initialisieren
  Future<void> initialisieren() async {
    if (_initialized) return;

    // Web unterstützt keine lokalen Notifications
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Erinnerung planen
  Future<void> erinnerungPlanen({
    required String eintragId,
    required String titel,
    required DateTime zeitpunkt,
    String? beschreibung,
  }) async {
    if (kIsWeb || !_initialized) return;

    final id = eintragId.hashCode;

    final scheduledDate = tz.TZDateTime.from(zeitpunkt, tz.local);

    // Nicht in der Vergangenheit planen
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'kalender_erinnerungen',
      'Kalender-Erinnerungen',
      channelDescription: 'Erinnerungen an Kalender-Termine',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      titel,
      beschreibung ?? 'Termin steht an',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Erinnerung abbrechen
  Future<void> erinnerungAbbrechen(String eintragId) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(eintragId.hashCode);
  }
}

/// Provider für den NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
