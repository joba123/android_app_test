/// Was die App über den Menschen weiß, der sie benutzt.
///
/// Bewusst wenig: ein Vorname für die Anrede und ein Tagesziel. Beides ist
/// freiwillig und bleibt auf dem Gerät, solange kein Konto verbunden ist.
class UserProfile {
  const UserProfile({this.name, this.dailyGoal = defaultDailyGoal});

  /// Der Vorname für die Begrüßung. `null` heißt: ohne Namen grüßen.
  final String? name;

  /// Wie viele Aufgaben am Tag angepeilt werden.
  final int dailyGoal;

  static const int defaultDailyGoal = 20;

  /// Zur Auswahl in den Einstellungen. Mehr als 50 wäre kein Ziel mehr,
  /// sondern ein Vorwurf.
  static const List<int> goalChoices = [10, 20, 30, 50];

  static const UserProfile empty = UserProfile();

  /// „Guten Morgen" bis 11 Uhr, „Guten Abend" ab 18 Uhr, dazwischen
  /// „Guten Tag" – die Grenzen, die im Deutschen üblich sind.
  String greeting(DateTime now) {
    if (now.hour < 11) return 'Guten Morgen';
    if (now.hour < 18) return 'Guten Tag';
    return 'Guten Abend';
  }

  /// Der Name, wie er unter der Begrüßung steht. Ohne Namen steht dort das,
  /// worum es geht – nicht etwa ein Platzhalter.
  String get headline => name?.trim().isNotEmpty ?? false
      ? name!.trim()
      : 'Deine Vorbereitung';

  UserProfile copyWith({String? name, int? dailyGoal, bool clearName = false}) {
    return UserProfile(
      name: clearName ? null : (name ?? this.name),
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        'dailyGoal': dailyGoal,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final raw = json['name'];
    final goal = json['dailyGoal'];

    return UserProfile(
      name: raw is String && raw.trim().isNotEmpty ? raw.trim() : null,
      dailyGoal: goal is int && goal > 0 ? goal : defaultDailyGoal,
    );
  }
}
