import 'package:einstellungstest_trainer/models/field_of_study.dart';

/// Eine Prüfung, auf die hingearbeitet wird.
///
/// Mehrere davon sind der Normalfall: Wer sich bei Polizei und Bahn bewirbt,
/// bereitet zwei Verfahren vor, die verschiedene Themen verlangen. Deshalb
/// hängt der Leitfaden an der Prüfung und nicht am Nutzer.
///
/// Ein Termin ist ausdrücklich **nicht** nötig. Wer noch keinen hat, übt auf
/// die Fachrichtung hin; der Countdown bleibt dann einfach leer.
class ExamPlan {
  const ExamPlan({
    required this.id,
    required this.title,
    required this.field,
    required this.createdAt,
    this.date,
  });

  final String id;

  /// Frei wählbar, etwa „Polizei Niedersachsen".
  final String title;

  final FieldOfStudy field;

  /// Optionaler Prüfungstermin.
  final DateTime? date;

  final DateTime createdAt;

  /// Tage bis zur Prüfung, `null` ohne Termin.
  int? daysUntil(DateTime now) {
    final target = date;
    if (target == null) return null;

    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(target.year, target.month, target.day);
    return examDay.difference(today).inDays;
  }

  ExamPlan copyWith({
    String? title,
    FieldOfStudy? field,
    DateTime? date,
    bool clearDate = false,
  }) {
    return ExamPlan(
      id: id,
      title: title ?? this.title,
      field: field ?? this.field,
      date: clearDate ? null : (date ?? this.date),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'field': field.id,
        if (date != null) 'date': date!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExamPlan.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    final rawCreated = json['createdAt'];

    return ExamPlan(
      id: json['id'] as String? ?? 'plan',
      title: json['title'] as String? ?? 'Meine Prüfung',
      field: FieldOfStudy.fromId(json['field'] as String? ?? 'general'),
      date: rawDate is String ? DateTime.tryParse(rawDate)?.toLocal() : null,
      createdAt: rawCreated is String
          ? DateTime.tryParse(rawCreated)?.toLocal() ?? DateTime(2026)
          : DateTime(2026),
    );
  }
}
