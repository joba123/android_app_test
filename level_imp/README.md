# Level Imp – Ein total faires Spiel™

Ein minimalistischer Troll-Plattformer in Flutter, inspiriert von *Level Devil*.
Ziel jedes Levels: die Tür erreichen. Das Level hat allerdings andere Pläne –
Böden stürzen ein, Stacheln tauchen auf, Türen laufen weg, die Schwerkraft
dreht sich um.

## Level

| # | Titel | Gemeinheit |
|---|-------|------------|
| 1 | Der erste Schritt | Boden bricht weg |
| 2 | Spitze! | Stacheln springen hoch, Tür rutscht weg |
| 3 | Kopf einziehen | Deckenblöcke zerquetschen |
| 4 | Die Tür ist gleich da | Tür flieht nach oben |
| 5 | Alles wie immer | Steuerung vertauscht – bis sie es nicht mehr ist |
| 6 | Unsichtbare Hilfe | Unsichtbare Blöcke als Treppe |
| 7 | Sägewerk | Patrouillierende und fallende Sägen |
| 8 | Oben ist unten | Schwerkraft dreht sich um |
| 9 | Bröselboden | Boden zerbröselt unter den Füßen |
| 10 | Platzangst | Die Wand schiebt dich vor sich her |
| 11 | Vertrauensfrage | Falsche Tür, Boden- und Stachelfalle |
| 12 | Das Finale | Alles auf einmal |

## Steuerung

- Touch: ← / → links unten, Springen rechts unten (länger halten = höher)
- Tastatur: Pfeiltasten oder A/D, Leertaste/W/↑ zum Springen, Esc = Pause

## Projektstruktur

- `lib/game/engine.dart` – Physik, Kollision und Fallen-System (reines Dart, testbar)
- `lib/game/levels.dart` – alle Level als ASCII-Karten plus Fallen-Skripte
- `lib/game/painter.dart` – Rendering mit `CustomPainter`
- `lib/ui/` – Menü, Levelauswahl, Spiel-Screen, Siegesbildschirm
- `test/levels_test.dart` – ein Bot spielt jedes Level durch (Lösbarkeit) und
  prüft, dass einfaches Rechtslaufen in Fallen-Leveln scheitert

## Neues Level bauen

Ein Level ist eine 32×15-Karte. Legende: `#` Wand, `P` Start, `D` Tür,
`^ v < >` Stacheln, `O` Säge, `c` Bröselboden, `F` falsche Tür, `U` hängende Tür.
Eigene Buchstaben werden im `legend` des Levels als Gruppen definiert und über
`Trap(Bedingung, [Aktionen])` gesteuert – z. B. `Fall`, `Show`, `MoveTo`,
`MovePath`, `SetReversed`, `SetGravity`. Danach in `test/levels_test.dart`
eine Bot-Lösung ergänzen.

## Bauen

```bash
flutter pub get
flutter test
flutter run            # auf Gerät/Emulator
flutter build apk      # Android
flutter build ios      # iOS (auf macOS)
```

In GitHub: **Actions → Level Imp (Flutter) → Run workflow** baut die APK und
stellt sie als Artefakt `level-imp-apk` bereit. Bei Pushes/PRs laufen nur
Analyse und Tests.
