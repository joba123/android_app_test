/// Der hinterlegte Testtermin.
///
/// [updatedAt] wird beim Zusammenführen mit der Cloud gebraucht: Ist auf zwei
/// Geräten ein Termin gesetzt, gewinnt die jüngere Änderung.
class ExamDate {
  const ExamDate({
    required this.date,
    required this.updatedAt,
    this.label,
  });

  final DateTime date;
  final DateTime updatedAt;

  /// Freitext wie "Polizei NRW, mittlerer Dienst".
  final String? label;

  /// Tage bis zum Termin, gerechnet ab dem übergebenen Tag.
  /// Negativ, wenn der Termin vorbei ist.
  int daysUntil(DateTime now) {
    final target = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return target.difference(today).inDays;
  }

  bool isPast(DateTime now) => daysUntil(now) < 0;

  /// Kurze Beschreibung für die Startseite.
  String describe(DateTime now) {
    final days = daysUntil(now);
    return switch (days) {
      < 0 => 'Termin liegt zurück',
      0 => 'Heute ist es so weit',
      1 => 'Noch 1 Tag',
      _ => 'Noch $days Tage',
    };
  }

  /// Vergleicht Termin und Beschriftung, nicht den Änderungszeitstempel.
  ///
  /// Ein Abgleich, der denselben Termin zurückbringt, soll die Erinnerungen
  /// nicht ohne Grund neu planen.
  @override
  bool operator ==(Object other) =>
      other is ExamDate && other.date == date && other.label == label;

  @override
  int get hashCode => Object.hash(date, label);

  Map<String, dynamic> toJson() => {
        'date': date.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'label': label,
      };

  static ExamDate? fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date'] as String? ?? '');
    if (date == null) return null;

    return ExamDate(
      date: date.toLocal(),
      // Wie beim Datum zurück in die lokale Zone: Gespeichert wird in UTC,
      // gearbeitet wird lokal.
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
              date.toLocal(),
      label: json['label'] as String?,
    );
  }
}
