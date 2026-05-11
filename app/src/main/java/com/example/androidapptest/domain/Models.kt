package com.example.androidapptest.domain

enum class Category(val label: String, val emoji: String) {
    CITIES("Städte", "🏙️"),
    FOOTBALL("Fußball", "⚽"),
    CARS("Autos", "🚗"),
    EVERYDAY("Preise & Alltag", "🛒"),
    STATES("Bundesländer", "🇩🇪"),
    COMPANIES("Unternehmen", "🏢"),
    MIXED("Gemischt", "✨")
}

data class QuizQuestion(
    val title: String,
    val subtitle: String,
    val value: Long,
    val formattedValue: String,
    val category: Category
)

data class GameStats(
    val highScore: Int = 0,
    val gamesPlayed: Int = 0,
    val bestStreak: Int = 0,
    val correctAnswers: Int = 0,
    val wrongAnswers: Int = 0
) {
    val accuracy: Int
        get() {
            val total = correctAnswers + wrongAnswers
            return if (total == 0) 0 else ((correctAnswers.toFloat() / total) * 100).toInt()
        }
}
