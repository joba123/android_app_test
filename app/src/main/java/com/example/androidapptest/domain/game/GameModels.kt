package com.example.androidapptest.domain.game

import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.domain.stats.Stats

data class GameUiState(
    val mode: GameMode = GameMode.general(),
    val referenceItem: ComparisonItem? = null,
    val comparisonItem: ComparisonItem? = null,
    val score: Int = 0,
    val streak: Int = 0,
    val currentHighScore: Int = 0,
    val isAnswerRevealed: Boolean = false,
    val lastAnswerCorrect: Boolean? = null,
    val gameOver: Boolean = false,
    val showGameOverStats: Boolean = false,
    val isNewHighScore: Boolean = false,
    val stats: Stats = Stats(),
    val errorMessage: String? = null
)

enum class Guess {
    Higher,
    Lower
}
