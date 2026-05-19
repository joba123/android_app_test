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
    val previousHighScore: Int = 0,
    val isAnswerRevealed: Boolean = false,
    val lastAnswerCorrect: Boolean? = null,
    val runStatus: RunStatus = RunStatus.Playing,
    val isNewHighScore: Boolean = false,
    val stats: Stats = Stats(),
    val errorMessage: String? = null,
    val reviveErrorMessage: String? = null
) {
    val gameOver: Boolean
        get() = runStatus == RunStatus.GameOver
}

enum class RunStatus {
    Playing,
    LostButCanRevive,
    Reviving,
    GameOver
}

enum class Guess {
    Higher,
    Lower
}
