/// Die drei Trainingsmodi der App.
///
/// Liegt in einer eigenen Datei, weil sowohl der laufende Sitzungszustand
/// ([QuizSession]) als auch der persistierte Verlauf ([TrainingSession])
/// darauf zugreifen.
enum SessionMode {
  practice(id: 'practice', label: 'Übungsmodus'),
  sprint(id: 'sprint', label: 'Sprint-Modus'),
  simulation(id: 'simulation', label: 'Testsimulation');

  const SessionMode({required this.id, required this.label});

  /// Stabiler Schlüssel für die Persistenz.
  final String id;

  final String label;

  static SessionMode fromId(String id) {
    return values.firstWhere(
      (mode) => mode.id == id,
      orElse: () => SessionMode.practice,
    );
  }
}
