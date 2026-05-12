package com.example.androidapptest.domain

data class Stats(
    val highScore: Int = 0,
    val gamesPlayed: Int = 0,
    val bestStreak: Int = 0,
    val correctAnswers: Int = 0,
    val wrongAnswers: Int = 0
) {
    val accuracy: Int
        get() {
            val total = correctAnswers + wrongAnswers
            return if (total == 0) 0 else ((correctAnswers * 100f) / total).toInt()
        }
}

data class GameUiState(
    val category: QuizCategory = QuizCategory.Mixed,
    val leftItem: QuizItem? = null,
    val rightItem: QuizItem? = null,
    val score: Int = 0,
    val streak: Int = 0,
    val lives: Int = 3,
    val isAnswerRevealed: Boolean = false,
    val lastAnswerCorrect: Boolean? = null,
    val gameOver: Boolean = false,
    val stats: Stats = Stats()
)

enum class Guess {
    Higher,
    Lower
}
