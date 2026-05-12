package com.example.androidapptest.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.example.androidapptest.domain.QuizCategory
import com.example.androidapptest.domain.Stats
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
                emit(androidx.datastore.preferences.core.emptyPreferences())
            } else {
                throw exception
            }
        }
        .map { preferences ->
            Stats(
                highScore = preferences[Keys.HighScore] ?: 0,
                gamesPlayed = preferences[Keys.GamesPlayed] ?: 0,
                bestStreak = preferences[Keys.BestStreak] ?: 0,
                correctAnswers = preferences[Keys.CorrectAnswers] ?: 0,
                wrongAnswers = preferences[Keys.WrongAnswers] ?: 0,
                selectedCategory = preferences[Keys.SelectedCategory]?.let { storedName ->
                    QuizCategory.entries.find { it.name == storedName }
                }
            )
        }

    suspend fun saveSelectedCategory(category: QuizCategory) {
        dataStore.edit { preferences ->
            preferences[Keys.SelectedCategory] = category.name
        }
    }

    suspend fun recordGameOver(
        score: Int,
        bestStreakInGame: Int,
        correctAnswersInGame: Int,
        wrongAnswersInGame: Int,
        selectedCategory: QuizCategory
    ) {
        dataStore.edit { preferences ->
            val currentHighScore = preferences[Keys.HighScore] ?: 0
            val currentBestStreak = preferences[Keys.BestStreak] ?: 0
            preferences[Keys.HighScore] = maxOf(currentHighScore, score)
            preferences[Keys.GamesPlayed] = (preferences[Keys.GamesPlayed] ?: 0) + 1
            preferences[Keys.BestStreak] = maxOf(currentBestStreak, bestStreakInGame)
            preferences[Keys.CorrectAnswers] = (preferences[Keys.CorrectAnswers] ?: 0) + correctAnswersInGame
            preferences[Keys.WrongAnswers] = (preferences[Keys.WrongAnswers] ?: 0) + wrongAnswersInGame
            preferences[Keys.SelectedCategory] = selectedCategory.name
        }
    }

    private object Keys {
        val HighScore = intPreferencesKey("highscore")
        val GamesPlayed = intPreferencesKey("games_played")
        val BestStreak = intPreferencesKey("best_streak")
        val CorrectAnswers = intPreferencesKey("correct_answers")
        val WrongAnswers = intPreferencesKey("wrong_answers")
        val SelectedCategory = stringPreferencesKey("selected_category")
    }
}
