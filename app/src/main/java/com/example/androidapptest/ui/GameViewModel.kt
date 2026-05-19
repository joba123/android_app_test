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
import com.example.androidapptest.domain.game.RunStatus
import com.example.androidapptest.domain.stats.ModeStatSummary
import com.example.androidapptest.domain.stats.Stats
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

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
    private var lastVisibleItemIds: Set<Int> = emptySet()

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
        val reference = current.referenceItem ?: return
        val comparison = current.comparisonItem ?: return
        if (current.isAnswerRevealed || current.runStatus != RunStatus.Playing) return

        val isCorrect = when (guess) {
            Guess.Higher -> comparison.value >= reference.value
            Guess.Lower -> comparison.value <= reference.value
        }
        val newScore = if (isCorrect) current.score + 1 else current.score
        val newStreak = if (isCorrect) current.streak + 1 else current.streak

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
                currentHighScore = maxOf(current.currentHighScore, newScore),
                isAnswerRevealed = true,
                lastAnswerCorrect = isCorrect,
                runStatus = if (isCorrect) RunStatus.Playing else RunStatus.LostButCanRevive,
                isNewHighScore = false,
                errorMessage = null,
                reviveErrorMessage = null
            )
        }
    }

    fun nextRound() {
        val current = _uiState.value
        if (current.runStatus != RunStatus.Playing) return
        val currentReference = current.referenceItem ?: return
        val currentComparison = current.comparisonItem ?: return
        val nextReference = if (current.isAnswerRevealed && current.lastAnswerCorrect == true) {
            currentComparison
        } else {
            currentReference
        }
        val nextComparison = nextComparisonFor(
            mode = current.mode,
            reference = nextReference,
            excludedIds = setOf(currentReference.id, currentComparison.id) + lastVisibleItemIds
        )
        if (nextComparison == null) {
            _uiState.update {
                it.copy(errorMessage = "Für diesen Modus gibt es noch nicht genug vergleichbare Items.")
            }
            return
        }
        lastVisibleItemIds = setOf(nextReference.id, nextComparison.id)
        _uiState.update {
            it.copy(
                referenceItem = nextReference,
                comparisonItem = nextComparison,
                isAnswerRevealed = false,
                lastAnswerCorrect = null,
                errorMessage = null
            )
        }
    }

    fun finishGameFromNavigation() {
        val current = _uiState.value
        if (current.runStatus == RunStatus.LostButCanRevive || current.runStatus == RunStatus.Reviving) {
            finishRun()
        }
    }

    fun beginReviveAttempt(): Boolean {
        if (_uiState.value.runStatus != RunStatus.LostButCanRevive) return false
        _uiState.update {
            it.copy(
                runStatus = RunStatus.Reviving,
                reviveErrorMessage = null,
                errorMessage = null
            )
        }
        return true
    }

    fun reviveFailed(message: String) {
        if (_uiState.value.runStatus != RunStatus.Reviving) return
        _uiState.update {
            it.copy(
                runStatus = RunStatus.LostButCanRevive,
                reviveErrorMessage = message
            )
        }
    }

    fun finishRun() {
        val current = _uiState.value
        if (current.runStatus == RunStatus.GameOver) return

        val previousHighScore = current.previousHighScore
        _uiState.update {
            it.copy(
                runStatus = RunStatus.GameOver,
                isAnswerRevealed = true,
                lastAnswerCorrect = false,
                currentHighScore = maxOf(previousHighScore, current.score),
                isNewHighScore = current.score > previousHighScore,
                reviveErrorMessage = null,
                errorMessage = null
            )
        }
        recordGameOverOnce()
    }

    fun continueAfterRevive() {
        val current = _uiState.value
        if (current.runStatus != RunStatus.Reviving) return
        val reference = current.referenceItem ?: return
        val currentComparison = current.comparisonItem
        val nextComparison = nextComparisonFor(
            mode = current.mode,
            reference = reference,
            excludedIds = setOfNotNull(reference.id, currentComparison?.id) + lastVisibleItemIds
        )
        if (nextComparison == null) {
            _uiState.update {
                it.copy(
                    runStatus = RunStatus.LostButCanRevive,
                    reviveErrorMessage = "Wiederbeleben ist gerade nicht möglich. Es gibt keine passende neue Karte.",
                    errorMessage = null
                )
            }
            return
        }
        lastVisibleItemIds = setOf(reference.id, nextComparison.id)
        _uiState.update {
            it.copy(
                comparisonItem = nextComparison,
                runStatus = RunStatus.Playing,
                isAnswerRevealed = false,
                lastAnswerCorrect = null,
                isNewHighScore = false,
                errorMessage = null,
                reviveErrorMessage = null
            )
        }
    }

    private fun startGame(mode: GameMode): Boolean {
        val firstPair = initialPair(mode)
        if (firstPair == null) {
            _uiState.update {
                it.copy(errorMessage = "Für diesen Modus gibt es noch nicht genug vergleichbare Items.")
            }
            return false
        }

        lastVisibleItemIds = setOf(firstPair.first.id, firstPair.second.id)
        correctAnswersInCurrentGame = 0
        wrongAnswersInCurrentGame = 0
        bestStreakInCurrentGame = 0
        gameOverRecorded = false

        val stats = _uiState.value.stats
        val previousHighScore = stats.highScoreFor(mode.statsKey)
        _uiState.update {
            GameUiState(
                mode = mode,
                referenceItem = firstPair.first,
                comparisonItem = firstPair.second,
                currentHighScore = previousHighScore,
                previousHighScore = previousHighScore,
                stats = stats
            )
        }
        viewModelScope.launch { statsRepository.saveSelectedMode(mode) }
        return true
    }

    private fun initialPair(mode: GameMode): Pair<ComparisonItem, ComparisonItem>? {
        val groups = comparableGroups(mode)
        if (groups.isEmpty()) return null

        repeat(24) {
            val group = groups.random()
            val reference = group.random()
            val comparison = group.filter { it.id != reference.id }.randomOrNull()
            if (comparison != null) return reference to comparison
        }

        val fallbackGroup = groups.first()
        val reference = fallbackGroup.first()
        return fallbackGroup.firstOrNull { it.id != reference.id }?.let { reference to it }
    }

    private fun nextComparisonFor(
        mode: GameMode,
        reference: ComparisonItem,
        excludedIds: Set<Int>
    ): ComparisonItem? =
        itemsComparableWith(mode, reference)
            .filter { it.id != reference.id && it.id !in excludedIds }
            .randomOrNull()

    private fun comparableGroups(mode: GameMode): List<List<ComparisonItem>> =
        if (mode.isGeneralMode) {
            repository.generalMetricGroups()
        } else {
            listOf(repository.itemsForSubCategory(mode.categoryId, mode.subcategoryId.orEmpty()))
        }.filter { it.size >= 2 }

    private fun itemsComparableWith(mode: GameMode, reference: ComparisonItem): List<ComparisonItem> =
        if (mode.isGeneralMode) {
            repository.allItems.filter { it.metricId == reference.metricId }
        } else {
            repository.itemsForSubCategory(mode.categoryId, mode.subcategoryId.orEmpty())
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
