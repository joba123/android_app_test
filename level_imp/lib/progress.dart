import 'package:shared_preferences/shared_preferences.dart';

/// Persists unlocked levels and death statistics.
class Progress {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Highest playable level (1-based).
  static int get unlocked => _prefs.getInt('unlocked') ?? 1;

  static int get totalDeaths => _prefs.getInt('totalDeaths') ?? 0;

  static int? bestDeaths(int level) => _prefs.getInt('best_$level');

  static Future<void> addDeath() =>
      _prefs.setInt('totalDeaths', totalDeaths + 1);

  static Future<void> completeLevel(int level, int deaths) async {
    if (level + 1 > unlocked) await _prefs.setInt('unlocked', level + 1);
    final best = bestDeaths(level);
    if (best == null || deaths < best) {
      await _prefs.setInt('best_$level', deaths);
    }
  }
}
