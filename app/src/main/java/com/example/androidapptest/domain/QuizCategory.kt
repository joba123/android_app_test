package com.example.androidapptest.domain

enum class QuizCategory(val title: String, val subtitle: String) {
    Cities("Städte", "Einwohner, Flächen und Wahrzeichen"),
    Football("Fußball", "Stadien, Titel und Rekorde"),
    Cars("Autos", "Modelle, Preise und Leistung"),
    DailyLife("Preise & Alltag", "Mieten, Löhne und Konsum"),
    States("Bundesländer", "Fläche, Einwohner und Wirtschaft"),
    Companies("Unternehmen", "Umsatz, Standorte und Mitarbeitende"),
    Mixed("Alle Kategorien", "Alles quer durch Deutschland")
}
