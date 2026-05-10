# Sternenlabyrinth

Eine vollständige Android-Spiel-App als kompaktes WebView-Spiel. **Sternenlabyrinth** ist ein taktisches Weltraum-Puzzle mit Hauptmenü, Levelauswahl, Einstellungen, lokal gespeichertem Fortschritt und sechs freischaltbaren Leveln.

## Spielprinzip

- Sammle in jedem Level alle gelben Energiekerne.
- Meide rote Pulsare, denn sie beenden den Versuch sofort.
- Erreiche danach das Portal, bevor das Zuglimit erreicht ist.
- Steuere per Wischgeste oder über die eingeblendeten Pfeiltasten.
- Einstellungen und freigeschaltete Level werden lokal auf dem Gerät gespeichert.

## Build APK lokal

In einer vollständigen Android-Entwicklungsumgebung mit Android SDK kann die Debug-APK so gebaut werden:

```bash
./gradlew assembleDebug
```

Die erzeugte APK liegt danach hier:

```text
app/build/outputs/apk/debug/app-debug.apk
```

## SDK-freier APK-Builder

Falls kein Android SDK vorhanden ist, erzeugt das Repository zusätzlich eine debug-signierte APK aus den enthaltenen Textquellen:

```bash
python3 scripts/build_manual_apk.py
```

Diese APK liegt danach hier:

```text
build/outputs/apk/debug/app-debug.apk
```

Generierte APKs, Keystores und Build-Ausgaben werden nicht versioniert.
