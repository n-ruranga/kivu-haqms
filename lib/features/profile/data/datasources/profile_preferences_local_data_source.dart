import 'package:shared_preferences/shared_preferences.dart';

class ProfilePreferencesLocalDataSource {
  ProfilePreferencesLocalDataSource({SharedPreferences? prefs})
      : _injectedPrefs = prefs;

  final SharedPreferences? _injectedPrefs;
  SharedPreferences? _cachedPrefs;

  static const _pushNotificationsPrefix = 'profile_push_notifications_';
  static const _appointmentRemindersPrefix = 'profile_appointment_reminders_';

  Future<SharedPreferences> get _storage async {
    return _injectedPrefs ?? (_cachedPrefs ??= await SharedPreferences.getInstance());
  }

  Future<bool> getPushNotificationsEnabled(String userId) async {
    final prefs = await _storage;
    return prefs.getBool('$_pushNotificationsPrefix$userId') ?? true;
  }

  Future<bool> getAppointmentRemindersEnabled(String userId) async {
    final prefs = await _storage;
    return prefs.getBool('$_appointmentRemindersPrefix$userId') ?? true;
  }

  Future<void> setPushNotificationsEnabled(String userId, bool value) async {
    final prefs = await _storage;
    await prefs.setBool('$_pushNotificationsPrefix$userId', value);
  }

  Future<void> setAppointmentRemindersEnabled(String userId, bool value) async {
    final prefs = await _storage;
    await prefs.setBool('$_appointmentRemindersPrefix$userId', value);
  }
}
