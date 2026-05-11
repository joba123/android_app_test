package com.example.androidapptest.ui

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.example.androidapptest.data.QuestionRepository
import com.example.androidapptest.data.StatsRepository
import com.example.androidapptest.domain.Category
import com.example.androidapptest.domain.QuizQuestion

enum class AppScreen { HOME, GAME, CATEGORIES, STATS }
enum class GuessFeedback { CORRECT, WRONG }

data class GameUiState(
    val screen: AppScreen = AppScreen.HOME,
    val selectedCategory: Category = Category.MIXED,
    val leftQuestion: QuizQuestion? = null,
    val rightQuestion: QuizQuestion? = null,
    val score: Int = 0,
    val streak: Int = 0,
    val lives: Int = 3,
    val feedback: GuessFeedback? = null,
    val isRevealed: Boolean = false,
    val isRoundLocked: Boolean = false,
    val gameOver: Boolean = false
)

class GameViewModel(context: Context) {
    private val questionRepository = QuestionRepository()
    private val statsRepository = StatsRepository(context.applicationContext)
    private val handler = Handler(Looper.getMainLooper())
    private val listeners = mutableListOf<(GameUiState) -> Unit>()
    private var activeDeck: List<QuizQuestion> = questionRepository.getQuestions(Category.MIXED)

    var state: GameUiState = GameUiState()
        private set

    val stats get() = statsRepository.loadStats()

    fun observe(listener: (GameUiState) -> Unit) {
        listeners += listener
        listener(state)
    }

    fun showHome() = setState(state.copy(screen = AppScreen.HOME))
    fun showCategories() = setState(state.copy(screen = AppScreen.CATEGORIES))
    fun showStats() = setState(state.copy(screen = AppScreen.STATS))

    fun startGame(category: Category = Category.MIXED) {
        activeDeck = questionRepository.getQuestions(category).shuffled()
        val pair = nextPair()
        setState(GameUiState(screen = AppScreen.GAME, selectedCategory = category, leftQuestion = pair.first, rightQuestion = pair.second))
    }

    fun guessHigher() = answer(expectHigher = true)
    fun guessLower() = answer(expectHigher = false)
    fun restartCurrentGame() = startGame(state.selectedCategory)

    private fun answer(expectHigher: Boolean) {
        val left = state.leftQuestion ?: return
        val right = state.rightQuestion ?: return
        if (state.isRoundLocked || state.gameOver) return

        val isCorrect = expectHigher == (right.value >= left.value)
        val newScore = if (isCorrect) state.score + 1 else state.score
        val newStreak = if (isCorrect) state.streak + 1 else 0
        val newLives = if (isCorrect) state.lives else state.lives - 1
        val newGameOver = newLives <= 0

        statsRepository.recordAnswer(isCorrect, newScore, newStreak)
        if (newGameOver) statsRepository.recordGameFinished(newScore, maxOf(state.streak, newStreak))

        setState(state.copy(
            score = newScore,
            streak = newStreak,
            lives = newLives.coerceAtLeast(0),
            feedback = if (isCorrect) GuessFeedback.CORRECT else GuessFeedback.WRONG,
            isRevealed = true,
            isRoundLocked = true,
            gameOver = newGameOver
        ))

        if (!newGameOver) handler.postDelayed({ moveToNextRound() }, 1050)
    }

    private fun moveToNextRound() {
        val pair = nextPair(previousRight = state.rightQuestion)
        setState(state.copy(leftQuestion = pair.first, rightQuestion = pair.second, feedback = null, isRevealed = false, isRoundLocked = false))
    }

    private fun nextPair(previousRight: QuizQuestion? = null): Pair<QuizQuestion, QuizQuestion> {
        val left = previousRight ?: activeDeck.random()
        var right = activeDeck.random()
        while (right == left) right = activeDeck.random()
        return left to right
    }

    private fun setState(newState: GameUiState) {
        state = newState
        listeners.forEach { it(state) }
    }
}
