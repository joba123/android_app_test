package com.example.androidapptest.ui

import androidx.lifecycle.ViewModel
import com.example.androidapptest.data.QuestionRepository
import com.example.androidapptest.domain.GameUiState
import com.example.androidapptest.domain.Guess
import com.example.androidapptest.domain.QuizCategory
import com.example.androidapptest.domain.QuizItem
import com.example.androidapptest.domain.Stats
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class GameViewModel(
    private val repository: QuestionRepository = QuestionRepository()
) : ViewModel() {
    private val _uiState = MutableStateFlow(GameUiState())
    val uiState: StateFlow<GameUiState> = _uiState.asStateFlow()

    val categories: List<QuizCategory> = repository.categories

    private var pool: List<QuizItem> = repository.getQuestions(QuizCategory.Mixed)
    private var stats = Stats()
    private var lastItemId: Int? = null

    init {
        startGame(QuizCategory.Mixed)
    }

    fun startGame(category: QuizCategory) {
        pool = repository.getQuestions(category).ifEmpty { repository.getQuestions(QuizCategory.Mixed) }
        val first = randomItem(excluding = null)
        val second = randomItem(excluding = first.id)
        lastItemId = second.id
        _uiState.value = GameUiState(
            category = category,
            leftItem = first,
            rightItem = second,
            stats = stats
        )
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

        stats = stats.copy(
            highScore = maxOf(stats.highScore, newScore),
            bestStreak = maxOf(stats.bestStreak, newStreak),
            correctAnswers = stats.correctAnswers + if (isCorrect) 1 else 0,
            wrongAnswers = stats.wrongAnswers + if (isCorrect) 0 else 1,
            gamesPlayed = stats.gamesPlayed + if (isGameOver) 1 else 0
        )

        _uiState.update {
            it.copy(
                score = newScore,
                streak = newStreak,
                lives = newLives,
                isAnswerRevealed = true,
                lastAnswerCorrect = isCorrect,
                gameOver = isGameOver,
                stats = stats
            )
        }
    }

    fun nextRound() {
        val current = _uiState.value
        val right = current.rightItem ?: return
        if (current.gameOver) return
        val next = randomItem(excluding = right.id)
        lastItemId = next.id
        _uiState.update {
            it.copy(
                leftItem = right,
                rightItem = next,
                isAnswerRevealed = false,
                lastAnswerCorrect = null
            )
        }
    }

    fun finishGameFromNavigation() {
        val current = _uiState.value
        if (current.score > 0 || current.lives < 3) {
            stats = stats.copy(
                highScore = maxOf(stats.highScore, current.score),
                bestStreak = maxOf(stats.bestStreak, current.streak),
                gamesPlayed = stats.gamesPlayed + 1
            )
            _uiState.update { it.copy(stats = stats) }
        }
    }

    private fun randomItem(excluding: Int?): QuizItem {
        val candidates = pool.filter { it.id != excluding && it.id != lastItemId }
            .ifEmpty { pool.filter { it.id != excluding } }
            .ifEmpty { pool }
        return candidates.random()
    }
}
