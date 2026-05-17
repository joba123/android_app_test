package com.example.androidapptest.domain.stats

data class Stats(
    val overallHighScore: Int = 0,
    val gamesPlayed: Int = 0,
    val bestStreak: Int = 0,
    val correctAnswers: Int = 0,
    val wrongAnswers: Int = 0,
    val selectedModeKey: String? = null,
    val selectedModeLabel: String? = null,
    val modeHighScores: Map<String, Int> = emptyMap(),
    val modeBestStreaks: Map<String, Int> = emptyMap(),
    val modeGamesPlayed: Map<String, Int> = emptyMap()
) {
    val accuracy: Int
        get() {
            val total = correctAnswers + wrongAnswers
            return if (total == 0) 0 else ((correctAnswers * 100f) / total).toInt()
        }

    val generalHighScore: Int
        get() = modeHighScores["general"] ?: 0

    fun highScoreFor(modeKey: String): Int = modeHighScores[modeKey] ?: 0

    fun bestStreakFor(modeKey: String): Int = modeBestStreaks[modeKey] ?: 0
}

data class ModeStatSummary(
    val key: String,
    val title: String,
    val subtitle: String,
    val highScore: Int,
    val bestStreak: Int,
    val gamesPlayed: Int
)
