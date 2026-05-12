package com.example.androidapptest.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.androidapptest.data.QuestionRepository
import com.example.androidapptest.data.StatsRepository
import com.example.androidapptest.domain.GameUiState
import com.example.androidapptest.domain.Guess
import com.example.androidapptest.domain.QuizCategory
import com.example.androidapptest.domain.QuizItem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class GameViewModel(
    private val statsRepository: StatsRepository,
    private val repository: QuestionRepository = QuestionRepository()
) : ViewModel() {
    private val _uiState = MutableStateFlow(GameUiState())
    val uiState: StateFlow<GameUiState> = _uiState.asStateFlow()

    val categories: List<QuizCategory> = repository.categories

    private var pool: List<QuizItem> = repository.getQuestions(QuizCategory.Mixed)
    private var lastItemId: Int? = null
    private var correctAnswersInCurrentGame = 0
    private var wrongAnswersInCurrentGame = 0
    private var bestStreakInCurrentGame = 0
    private var gameOverRecorded = false

    init {
        viewModelScope.launch {
            statsRepository.stats.collect { savedStats ->
                _uiState.update { it.copy(stats = savedStats) }
            }
        }
        startGame(QuizCategory.Mixed)
    }

    fun startGame(category: QuizCategory) {
        pool = repository.getQuestions(category).ifEmpty { repository.getQuestions(QuizCategory.Mixed) }
        val first = randomItem(excluding = null)
        val second = randomItem(excluding = first.id)
        lastItemId = second.id
        correctAnswersInCurrentGame = 0
        wrongAnswersInCurrentGame = 0
        bestStreakInCurrentGame = 0
        gameOverRecorded = false
        _uiState.update { current ->
            GameUiState(
                category = category,
                leftItem = first,
                rightItem = second,
                stats = current.stats.copy(selectedCategory = category)
            )
        }
        viewModelScope.launch { statsRepository.saveSelectedCategory(category) }
    }

    fun submitGuess(guess: Guess) {
        val current = _uiState.value
        val left = current.leftItem ?: return
        val right = current.rightItem ?: return
        if (current.isAnswerRevealed || current.gameOver) return

        val isCorrect = when (guess) {
            Guess.Higher -> right.value >= left.value
            Guess.Lower -> right.value <= left.value
        }
        val newScore = if (isCorrect) current.score + 1 else current.score
        val newStreak = if (isCorrect) current.streak + 1 else 0
        val newLives = if (isCorrect) current.lives else current.lives - 1
        val isGameOver = newLives <= 0

        if (isCorrect) {
            correctAnswersInCurrentGame += 1
        } else {
            wrongAnswersInCurrentGame += 1
        }
        bestStreakInCurrentGame = maxOf(bestStreakInCurrentGame, newStreak)

        _uiState.update {
            it.copy(
                score = newScore,
                streak = newStreak,
                lives = newLives,
                isAnswerRevealed = true,
                lastAnswerCorrect = isCorrect,
                gameOver = isGameOver,
                rewardedAdMessage = null
            )
        }

        if (isGameOver) recordGameOverOnce()
    }

    fun nextRound() {
        val current = _uiState.value
        val right = current.rightItem ?: return
        if (current.gameOver) return
        val next = randomItem(excluding = right.id, anchorValue = right.value, score = current.score)
        lastItemId = next.id
        _uiState.update {
            it.copy(
                leftItem = right,
                rightItem = next,
                isAnswerRevealed = false,
                lastAnswerCorrect = null,
                rewardedAdMessage = null
            )
        }
    }

    fun continueAfterRewardedAd() {
        val current = _uiState.value
        if (!current.gameOver) return
        _uiState.update {
            it.copy(
                lives = 1,
                gameOver = false,
                isAnswerRevealed = true,
                rewardedAdMessage = "Du hast 1 Leben erhalten. Weiter geht's!"
            )
        }
    }

    fun markRewardedAdUnavailable() {
        _uiState.update { it.copy(rewardedAdMessage = "Werbung ist gerade nicht verfügbar. Bitte versuche es später erneut.") }
    }

    fun finishGameFromNavigation() {
        val current = _uiState.value
        if (current.gameOver) {
            recordGameOverOnce()
        }
    }

    private fun recordGameOverOnce() {
        if (gameOverRecorded) return
        gameOverRecorded = true
        val current = _uiState.value
        viewModelScope.launch {
            statsRepository.recordGameOver(
                score = current.score,
                bestStreakInGame = bestStreakInCurrentGame,
                correctAnswersInGame = correctAnswersInCurrentGame,
                wrongAnswersInGame = wrongAnswersInCurrentGame,
                selectedCategory = current.category
            )
        }
    }

    private fun randomItem(excluding: Int?, anchorValue: Int? = null, score: Int = 0): QuizItem {
        val baseCandidates = pool.filter { it.id != excluding && it.id != lastItemId }
            .ifEmpty { pool.filter { it.id != excluding } }
            .ifEmpty { pool }
        if (anchorValue == null || score < 2) return baseCandidates.random()

        val similarityWindow = when {
            score >= 14 -> 0.18f
            score >= 9 -> 0.28f
            score >= 5 -> 0.42f
            else -> 0.65f
        }
        val lowerBound = (anchorValue * (1f - similarityWindow)).toInt()
        val upperBound = (anchorValue * (1f + similarityWindow)).toInt()
        val similarCandidates = baseCandidates.filter { it.value in lowerBound..upperBound }
        return similarCandidates.ifEmpty { baseCandidates.sortedBy { kotlin.math.abs(it.value - anchorValue) }.take(3) }.random()
    }

    class Factory(private val statsRepository: StatsRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(GameViewModel::class.java)) {
                return GameViewModel(statsRepository) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}
