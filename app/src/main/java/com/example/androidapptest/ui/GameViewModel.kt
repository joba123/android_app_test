package com.example.androidapptest.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.androidapptest.data.ComparisonRepository
import com.example.androidapptest.data.StatsRepository
import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.data.model.SubCategory
import com.example.androidapptest.domain.game.GameMode
import com.example.androidapptest.domain.game.GameUiState
import com.example.androidapptest.domain.game.Guess
import com.example.androidapptest.domain.stats.ModeStatSummary
import com.example.androidapptest.domain.stats.Stats
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlin.random.Random

class GameViewModel(
    private val statsRepository: StatsRepository,
    private val repository: ComparisonRepository = ComparisonRepository()
) : ViewModel() {
    private val _uiState = MutableStateFlow(GameUiState())
    val uiState: StateFlow<GameUiState> = _uiState.asStateFlow()

    val mainCategories: List<MainCategory> = repository.mainCategories

    private var gameOverRecorded = false
    private var correctAnswersInCurrentGame = 0
    private var wrongAnswersInCurrentGame = 0
    private var bestStreakInCurrentGame = 0
    private var lastPairIds: Set<Int> = emptySet()

    init {
        viewModelScope.launch {
            statsRepository.stats.collect { savedStats ->
                _uiState.update { state ->
                    state.copy(
                        stats = savedStats,
                        currentHighScore = maxOf(savedStats.highScoreFor(state.mode.statsKey), state.score)
                    )
                }
            }
        }
    }

    fun subCategoriesFor(categoryId: String): List<SubCategory> =
        repository.subCategoriesFor(categoryId)

    fun itemCount(categoryId: String, subCategoryId: String): Int =
        repository.itemCount(categoryId, subCategoryId)

    fun highScoreForMainCategory(category: MainCategory, stats: Stats): Int {
        if (category.isGeneral) return stats.generalHighScore
        return repository.subCategoriesFor(category.id)
            .maxOfOrNull { stats.highScoreFor(it.modeKey) }
            ?: 0
    }

    fun subCategorySummaries(categoryId: String, stats: Stats): List<ModeStatSummary> =
        repository.subCategoriesFor(categoryId).map { subCategory ->
            ModeStatSummary(
                key = subCategory.modeKey,
                title = subCategory.name,
                subtitle = subCategory.description,
                highScore = stats.highScoreFor(subCategory.modeKey),
                bestStreak = stats.bestStreakFor(subCategory.modeKey),
                gamesPlayed = stats.modeGamesPlayed[subCategory.modeKey] ?: 0
            )
        }

    fun topSubCategoryStats(stats: Stats): List<ModeStatSummary> =
        repository.subCategories
            .map { subCategory ->
                val category = repository.mainCategory(subCategory.categoryId)
                ModeStatSummary(
                    key = subCategory.modeKey,
                    title = "${category?.name.orEmpty()} · ${subCategory.name}",
                    subtitle = subCategory.description,
                    highScore = stats.highScoreFor(subCategory.modeKey),
                    bestStreak = stats.bestStreakFor(subCategory.modeKey),
                    gamesPlayed = stats.modeGamesPlayed[subCategory.modeKey] ?: 0
                )
            }
            .filter { it.highScore > 0 || it.gamesPlayed > 0 }
            .sortedByDescending { it.highScore }
            .take(6)

    fun startGeneralGame(): Boolean = startGame(GameMode.general())

    fun startSubCategoryGame(categoryId: String, subCategoryId: String): Boolean {
        val category = repository.mainCategory(categoryId) ?: return false
        val subCategory = repository.subCategory(categoryId, subCategoryId) ?: return false
        return startGame(GameMode.from(category, subCategory))
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

        if (isCorrect) {
            correctAnswersInCurrentGame += 1
        } else {
            wrongAnswersInCurrentGame += 1
        }
        bestStreakInCurrentGame = maxOf(bestStreakInCurrentGame, newStreak)

        val previousHighScore = current.stats.highScoreFor(current.mode.statsKey)
        _uiState.update {
            it.copy(
                score = newScore,
                streak = newStreak,
                currentHighScore = maxOf(current.currentHighScore, newScore),
                isAnswerRevealed = true,
                lastAnswerCorrect = isCorrect,
                gameOver = !isCorrect,
                isNewHighScore = !isCorrect && newScore > previousHighScore,
                errorMessage = null
            )
        }

        if (!isCorrect) recordGameOverOnce()
    }

    fun nextRound() {
        val current = _uiState.value
        if (current.gameOver) return
        val nextPair = nextPair(current.mode)
        if (nextPair == null) {
            _uiState.update {
                it.copy(errorMessage = "Für diesen Modus gibt es noch nicht genug vergleichbare Items.")
            }
            return
        }
        lastPairIds = setOf(nextPair.first.id, nextPair.second.id)
        _uiState.update {
            it.copy(
                leftItem = nextPair.first,
                rightItem = nextPair.second,
                isAnswerRevealed = false,
                lastAnswerCorrect = null,
                errorMessage = null
            )
        }
    }

    fun finishGameFromNavigation() {
        val current = _uiState.value
        if (current.gameOver) {
            recordGameOverOnce()
        }
    }

    fun revealGameOverStats() {
        _uiState.update { it.copy(showGameOverStats = true) }
    }

    fun continueAfterRevive() {
        _uiState.update { it.copy(gameOver = false, isAnswerRevealed = false, lastAnswerCorrect = null, showGameOverStats = false) }
        nextRound()
    }

    private fun startGame(mode: GameMode): Boolean {
        val firstPair = nextPair(mode, ignoreLastPair = true)
        if (firstPair == null) {
            _uiState.update {
                it.copy(errorMessage = "Für diesen Modus gibt es noch nicht genug vergleichbare Items.")
            }
            return false
        }

        lastPairIds = setOf(firstPair.first.id, firstPair.second.id)
        correctAnswersInCurrentGame = 0
        wrongAnswersInCurrentGame = 0
        bestStreakInCurrentGame = 0
        gameOverRecorded = false

        val stats = _uiState.value.stats
        _uiState.update {
            GameUiState(
                mode = mode,
                leftItem = firstPair.first,
                rightItem = firstPair.second,
                currentHighScore = stats.highScoreFor(mode.statsKey),
                showGameOverStats = false,
                stats = stats
            )
        }
        viewModelScope.launch { statsRepository.saveSelectedMode(mode) }
        return true
    }

    private fun nextPair(mode: GameMode, ignoreLastPair: Boolean = false): Pair<ComparisonItem, ComparisonItem>? {
        val groups = if (mode.isGeneralMode) {
            repository.generalMetricGroups()
        } else {
            listOf(repository.itemsForSubCategory(mode.categoryId, mode.subcategoryId.orEmpty()))
        }.filter { it.size >= 2 }

        if (groups.isEmpty()) return null

        repeat(24) {
            val group = groups.random()
            val first = group.random()
            val second = group.filter { it.id != first.id }.random()
            val pairIds = setOf(first.id, second.id)
            if (ignoreLastPair || pairIds != lastPairIds || group.size <= 2) {
                return first to second
            }
        }

        val fallbackGroup = groups.first()
        val shuffled = fallbackGroup.shuffled(Random.Default)
        return shuffled.getOrNull(0)?.let { first ->
            shuffled.firstOrNull { it.id != first.id }?.let { second -> first to second }
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
                selectedMode = current.mode
            )
        }
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
