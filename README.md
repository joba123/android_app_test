# Mehr oder Weniger: Deutschland

Native Android-Spiel-App in Kotlin mit dunklem Deutschland-Look. Das Quiz vergleicht lokale Dummy-Daten aus Kategorien wie Städte, Fußball, Autos, Preise & Alltag, Bundesländer und Unternehmen.

## Features

- HomeScreen mit Endlosmodus, Kategorien, deaktivierter Daily Challenge und Statistiken.
- GameScreen mit zwei großen Karten, Score/Streak, Leben, Höher/Weniger-Auswahl und Feedback.
- CategoryScreen mit sieben Kategorien.
- StatsScreen mit Highscore, gespielten Spielen, bester Streak, richtigen/falschen Antworten und Genauigkeit.
- Keine XML-Layouts; die UI wird vollständig programmatisch aufgebaut.
- Offline nutzbar, alle Fragen liegen lokal in der App.

## Build

In einer vollständigen Android-Entwicklungsumgebung mit Android SDK:

```bash
./gradlew :app:assembleDebug
```

Die Debug-APK wird unter `app/build/outputs/apk/debug/app-debug.apk` erzeugt.
