repo: joba123/android_app_test
branch: main

## Last sync
date: 2026-08-18T08:22:00Z

### Updated in this project
- Visuelles Design für „Einstellungstest Trainer" neu aufgesetzt (Design Component, 11 Screens + Tokens/Komponenten/Icon).
- Aus dem Repo übernommen: M3-Konventionen, deutsche Copy-Tonalität, AdMob-Banner-Slot, Button-/Karten-/StatTile-Muster.
- Nicht übernommen: Gold/Rot-Dark-Only-Theme des Higher-Lower-Quiz — es ist eine andere App im selben Repo-Sandkasten.

## Screen map
| Screen (Projekt) | Repo-Dateien (Referenz) |
| --- | --- |
| Alle Screens / Tokens | ui/theme/Color.kt, Theme.kt, Type.kt |
| Startseite | ui/screens/HomeScreen.kt, ui/components/PrimaryMenuButton.kt, StatTile.kt |
| Übungs-Auswahl | ui/screens/CategorySelectionScreen.kt, SubCategoryScreen.kt |
| Übungsrunde / Sprint / Simulation | ui/screens/GameScreen.kt, ui/components/QuizCard.kt, domain/game/GameMode.kt |
| Statistik / Auswertung | ui/screens/StatsScreen.kt, data/StatsRepository.kt |
| Einstellungen / Pro | ui/screens/SettingsScreen.kt, ads/AdMobManager.kt |
