package com.example.androidapptest.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.example.androidapptest.domain.game.GameMode
import com.example.androidapptest.domain.stats.Stats
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import java.io.IOException

private val Context.statsDataStore: DataStore<Preferences> by preferencesDataStore(name = "stats")

class StatsRepository(context: Context) {
    private val dataStore = context.applicationContext.statsDataStore

    val stats: Flow<Stats> = dataStore.data
        .catch { exception ->
            if (exception is IOException) {
                emit(emptyPreferences())
            } else {
                throw exception
            }
        }
        .map { preferences ->
            val namedValues = preferences.asMap().mapKeys { it.key.name }
            val modeHighScores = namedValues.intMapWithPrefix(Keys.HighScorePrefix)
            val modeBestStreaks = namedValues.intMapWithPrefix(Keys.ModeBestStreakPrefix)
            val modeGamesPlayed = namedValues.intMapWithPrefix(Keys.ModeGamesPlayedPrefix)
            val legacyHighScore = preferences[Keys.LegacyHighScore] ?: 0

            Stats(
                overallHighScore = maxOf(legacyHighScore, modeHighScores.values.maxOrNull() ?: 0),
                gamesPlayed = preferences[Keys.GamesPlayed] ?: 0,
                bestStreak = preferences[Keys.BestStreak] ?: 0,
                correctAnswers = preferences[Keys.CorrectAnswers] ?: 0,
                wrongAnswers = preferences[Keys.WrongAnswers] ?: 0,
                selectedModeKey = preferences[Keys.SelectedModeKey],
                selectedModeLabel = preferences[Keys.SelectedModeLabel],
                modeHighScores = modeHighScores,
                modeBestStreaks = modeBestStreaks,
                modeGamesPlayed = modeGamesPlayed
            )
        }

    suspend fun saveSelectedMode(mode: GameMode) {
        dataStore.edit { preferences ->
            preferences[Keys.SelectedModeKey] = mode.statsKey
            preferences[Keys.SelectedModeLabel] = mode.displayLabel()
        }
    }

    suspend fun recordGameOver(
        score: Int,
        bestStreakInGame: Int,
        correctAnswersInGame: Int,
        wrongAnswersInGame: Int,
        selectedMode: GameMode
    ) {
        dataStore.edit { preferences ->
            val modeKey = selectedMode.statsKey
            val highScoreKey = intPreferencesKey("${Keys.HighScorePrefix}$modeKey")
            val bestStreakKey = intPreferencesKey("${Keys.ModeBestStreakPrefix}$modeKey")
            val gamesPlayedKey = intPreferencesKey("${Keys.ModeGamesPlayedPrefix}$modeKey")

            preferences[highScoreKey] = maxOf(preferences[highScoreKey] ?: 0, score)
            preferences[bestStreakKey] = maxOf(preferences[bestStreakKey] ?: 0, bestStreakInGame)
            preferences[gamesPlayedKey] = (preferences[gamesPlayedKey] ?: 0) + 1
            preferences[Keys.LegacyHighScore] = maxOf(preferences[Keys.LegacyHighScore] ?: 0, score)
            preferences[Keys.GamesPlayed] = (preferences[Keys.GamesPlayed] ?: 0) + 1
            preferences[Keys.BestStreak] = maxOf(preferences[Keys.BestStreak] ?: 0, bestStreakInGame)
            preferences[Keys.CorrectAnswers] = (preferences[Keys.CorrectAnswers] ?: 0) + correctAnswersInGame
            preferences[Keys.WrongAnswers] = (preferences[Keys.WrongAnswers] ?: 0) + wrongAnswersInGame
            preferences[Keys.SelectedModeKey] = modeKey
            preferences[Keys.SelectedModeLabel] = selectedMode.displayLabel()
        }
    }

    private fun GameMode.displayLabel(): String =
        if (isGeneralMode) "Allgemein" else "$categoryName · ${subcategoryName.orEmpty()}"

    private fun Map<String, Any>.intMapWithPrefix(prefix: String): Map<String, Int> =
        filterKeys { it.startsWith(prefix) }
            .mapKeys { it.key.removePrefix(prefix) }
            .mapNotNull { (key, value) -> (value as? Int)?.let { key to it } }
            .toMap()

    private object Keys {
        const val HighScorePrefix = "highscore_"
        const val ModeBestStreakPrefix = "best_streak_"
        const val ModeGamesPlayedPrefix = "games_played_"

        val LegacyHighScore = intPreferencesKey("highscore")
        val GamesPlayed = intPreferencesKey("games_played")
        val BestStreak = intPreferencesKey("best_streak")
        val CorrectAnswers = intPreferencesKey("correct_answers")
        val WrongAnswers = intPreferencesKey("wrong_answers")
        val SelectedModeKey = stringPreferencesKey("selected_mode_key")
        val SelectedModeLabel = stringPreferencesKey("selected_mode_label")
    }
}
