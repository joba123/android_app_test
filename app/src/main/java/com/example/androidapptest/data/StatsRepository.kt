package com.example.androidapptest.data

import android.content.Context
import com.example.androidapptest.domain.GameStats

class StatsRepository(context: Context) {
    private val preferences = context.getSharedPreferences("mehr_oder_weniger_stats", Context.MODE_PRIVATE)

    fun loadStats(): GameStats = GameStats(
        highScore = preferences.getInt(KEY_HIGH_SCORE, 0),
        gamesPlayed = preferences.getInt(KEY_GAMES_PLAYED, 0),
        bestStreak = preferences.getInt(KEY_BEST_STREAK, 0),
        correctAnswers = preferences.getInt(KEY_CORRECT, 0),
        wrongAnswers = preferences.getInt(KEY_WRONG, 0)
    )

    fun recordAnswer(isCorrect: Boolean, score: Int, streak: Int) {
        val current = loadStats()
        save(current.copy(
            highScore = maxOf(current.highScore, score),
            bestStreak = maxOf(current.bestStreak, streak),
            correctAnswers = current.correctAnswers + if (isCorrect) 1 else 0,
            wrongAnswers = current.wrongAnswers + if (isCorrect) 0 else 1
        ))
    }

    fun recordGameFinished(score: Int, streak: Int) {
        val current = loadStats()
        save(current.copy(
            highScore = maxOf(current.highScore, score),
            gamesPlayed = current.gamesPlayed + 1,
            bestStreak = maxOf(current.bestStreak, streak)
        ))
    }

    private fun save(stats: GameStats) {
        preferences.edit()
            .putInt(KEY_HIGH_SCORE, stats.highScore)
            .putInt(KEY_GAMES_PLAYED, stats.gamesPlayed)
            .putInt(KEY_BEST_STREAK, stats.bestStreak)
            .putInt(KEY_CORRECT, stats.correctAnswers)
            .putInt(KEY_WRONG, stats.wrongAnswers)
            .apply()
    }

    private companion object {
        const val KEY_HIGH_SCORE = "high_score"
        const val KEY_GAMES_PLAYED = "games_played"
        const val KEY_BEST_STREAK = "best_streak"
        const val KEY_CORRECT = "correct_answers"
        const val KEY_WRONG = "wrong_answers"
    }
}
