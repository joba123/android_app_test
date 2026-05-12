# Handy-freundlicher Codex-Workflow

Dieser Workflow ist darauf ausgelegt, kleine Änderungen bequem vom Handy aus zu starten und zu prüfen. `main` bleibt dabei stabil; neue Features kommen über kleine Pull Requests und werden erst nach Review gemerged.

## 1. Per Handy ein Issue erstellen

1. Öffne das Repository in der GitHub-App oder im mobilen Browser.
2. Wechsle zu **Issues** und tippe auf **New issue**.
3. Beschreibe genau, was geändert werden soll:
   - gewünschtes Verhalten,
   - betroffene Bereiche,
   - Akzeptanzkriterien,
   - falls möglich Screenshots oder Beispiele.
4. Halte das Issue klein, damit Codex daraus einen überschaubaren Pull Request erstellen kann.
5. Erstelle das Issue und prüfe, ob Titel und Beschreibung eindeutig sind.

## 2. Wie Codex daraus einen Pull Request macht

1. Starte Codex mit Bezug auf das Issue oder übergib Codex den Issue-Link.
2. Codex liest die Anforderungen, nimmt nur die nötigen Änderungen vor und vermeidet große, unzusammenhängende Umbauten.
3. Codex erstellt einen Branch, committet die Änderung und öffnet einen Pull Request.
4. Der Pull Request sollte kurz erklären:
   - was geändert wurde,
   - welche Dateien betroffen sind,
   - welche Checks oder Tests ausgeführt wurden.

## 3. Pull Request am Handy prüfen und mergen

1. Öffne den Pull Request in GitHub.
2. Lies die Zusammenfassung und prüfe die geänderten Dateien im Tab **Files changed**.
3. Achte besonders darauf, ob die Änderung wirklich zum Issue passt und keine App-Logik außerhalb des Ziels verändert wurde.
4. Falls leichte Pull-Request-Checks vorhanden sind, warte auf deren Ergebnis. Diese Checks sollen nur schnelle Prüfungen ausführen und keinen APK-Build erzwingen.
5. Kommentiere Änderungswünsche direkt im Pull Request oder merge den Pull Request, wenn alles passt.

## 4. APK-Action danach manuell starten

Der APK-Build läuft nicht automatisch für Pull Requests. Dadurch werden Codex-PRs nicht durch eine kaputte oder aufwendige APK-Action blockiert.

So startest du den APK-Build manuell nach dem Merge:

1. Öffne im Repository den Tab **Actions**.
2. Wähle den Workflow **Build APK** aus.
3. Tippe auf **Run workflow**.
4. Wähle den gewünschten Branch aus, normalerweise `main` nach dem Merge.
5. Starte den Workflow und warte auf das Ergebnis.
6. Lade das APK-Artefakt aus dem abgeschlossenen Workflow-Lauf herunter oder nutze den Appetize.io-Link aus der Job-Zusammenfassung, falls der Upload konfiguriert ist.

## 5. Stabiler `main`, kleine Features

- `main` bleibt stabil und enthält nur geprüfte Änderungen.
- Features und Fixes werden in kleinen Pull Requests umgesetzt.
- APK-Builds werden bewusst manuell gestartet, wenn ein testbares Android-Paket gebraucht wird.
- Pull Requests bleiben dadurch leichter, schneller und besser vom Handy aus prüfbar.
