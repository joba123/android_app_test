package com.example.androidapptest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.androidapptest.ads.AdMobManager
import com.example.androidapptest.data.StatsRepository
import com.example.androidapptest.domain.game.RunStatus
import com.example.androidapptest.ui.GameViewModel
import com.example.androidapptest.ui.screens.GameScreen
import com.example.androidapptest.ui.screens.HomeScreen
import com.example.androidapptest.ui.screens.CategorySelectionScreen
import com.example.androidapptest.ui.screens.LegalInfoScreen
import com.example.androidapptest.ui.screens.SettingsScreen
import com.example.androidapptest.ui.screens.StatsScreen
import com.example.androidapptest.ui.screens.SubCategoryScreen
import com.example.androidapptest.ui.theme.DeutschlandQuizTheme

class MainActivity : ComponentActivity() {
    private lateinit var adMobManager: AdMobManager

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        adMobManager = AdMobManager(applicationContext)
        adMobManager.initialize()
        setContent {
            DeutschlandQuizTheme {
                DeutschlandQuizApp(activity = this, adMobManager = adMobManager)
            }
        }
    }
}

private enum class AppScreen {
    Home,
    Categories,
    SubCategories,
    Game,
    Stats,
    Settings,
    Privacy,
    Imprint
}

@Composable
private fun DeutschlandQuizApp(
    activity: ComponentActivity,
    adMobManager: AdMobManager,
    viewModel: GameViewModel = viewModel(
        factory = GameViewModel.Factory(StatsRepository(activity.applicationContext))
    )
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    var screen by remember { mutableStateOf(AppScreen.Home) }
    var gameReturnScreen by rememberSaveable { mutableStateOf(AppScreen.Home) }
    var selectedCategoryId by rememberSaveable { mutableStateOf<String?>(null) }
    var interstitialShownForGameOver by remember { mutableStateOf(false) }
    var endingRun by remember { mutableStateOf(false) }
    var soundEnabled by rememberSaveable { mutableStateOf(false) }
    var hapticsEnabled by rememberSaveable { mutableStateOf(true) }

    fun restartCurrentGame() {
        val mode = state.mode
        val started = if (mode.isGeneralMode) {
            viewModel.startGeneralGame()
        } else {
            viewModel.startSubCategoryGame(mode.categoryId, mode.subcategoryId.orEmpty())
        }
        if (started) {
            interstitialShownForGameOver = false
            endingRun = false
        }
    }

    fun finishRunAfterInterstitial() {
        if (endingRun || state.gameOver) return
        endingRun = true

        fun finishRun() {
            endingRun = false
            viewModel.finishRun()
        }

        if (interstitialShownForGameOver) {
            finishRun()
            return
        }

        interstitialShownForGameOver = true
        adMobManager.showInterstitialAfterGameOver(activity, onFinished = { finishRun() })
    }

    fun navigateBack() {
        when (screen) {
            AppScreen.Home -> Unit
            AppScreen.Game -> {
                if (state.runStatus == RunStatus.LostButCanRevive || state.runStatus == RunStatus.Reviving) {
                    finishRunAfterInterstitial()
                } else {
                    viewModel.finishGameFromNavigation()
                    screen = gameReturnScreen
                }
            }
            AppScreen.Categories,
            AppScreen.SubCategories,
            AppScreen.Stats,
            AppScreen.Settings -> screen = AppScreen.Home
            AppScreen.Privacy,
            AppScreen.Imprint -> screen = AppScreen.Settings
        }
    }

    BackHandler(enabled = screen != AppScreen.Home) {
        navigateBack()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        when (screen) {
            AppScreen.Home -> HomeScreen(
                categories = viewModel.mainCategories,
                featuredItems = viewModel.featuredMenuItems,
                overallHighScore = state.stats.overallHighScore,
                lastModeLabel = state.stats.selectedModeLabel,
                highScoreForCategory = { viewModel.highScoreForMainCategory(it, state.stats) },
                itemCountForCategory = viewModel::itemCountForMainCategory,
                sampleItemForCategory = viewModel::sampleItemForMainCategory,
                onPlay = { screen = AppScreen.Categories },
                onCategorySelected = {
                    selectedCategoryId = it.id
                    screen = AppScreen.SubCategories
                },
                onOpenStats = { screen = AppScreen.Stats },
                onOpenSettings = { screen = AppScreen.Settings }
            )
            AppScreen.Categories -> CategorySelectionScreen(
                categories = viewModel.mainCategories,
                highScoreForCategory = { viewModel.highScoreForMainCategory(it, state.stats) },
                itemCountForCategory = viewModel::itemCountForMainCategory,
                sampleItemForCategory = viewModel::sampleItemForMainCategory,
                onBack = { screen = AppScreen.Home },
                onCategorySelected = {
                    selectedCategoryId = it.id
                    screen = AppScreen.SubCategories
                }
            )

            AppScreen.SubCategories -> {
                val selectedCategory = viewModel.mainCategories.firstOrNull { it.id == selectedCategoryId }
                if (selectedCategory == null) {
                    screen = AppScreen.Home
                } else {
                    SubCategoryScreen(
                        category = selectedCategory,
                        subCategories = viewModel.subCategoriesFor(selectedCategory.id),
                        summaryFor = { subCategory ->
                            viewModel.subCategorySummaries(selectedCategory.id, state.stats)
                                .first { it.key == subCategory.modeKey }
                        },
                        itemCountFor = { viewModel.itemCount(it.categoryId, it.id) },
                        sampleItemFor = viewModel::sampleItemForSubCategory,
                        onBack = { screen = AppScreen.Home },
                        onSubCategorySelected = { subCategory ->
                            if (viewModel.startSubCategoryGame(selectedCategory.id, subCategory.id)) {
                                gameReturnScreen = AppScreen.SubCategories
                                interstitialShownForGameOver = false
                                endingRun = false
                                screen = AppScreen.Game
                            }
                        }
                    )
                }
            }

            AppScreen.Game -> GameScreen(
                state = state,
                onBack = { navigateBack() },
                hapticsEnabled = hapticsEnabled,
                onGuess = viewModel::submitGuess,
                onNextRound = viewModel::nextRound,
                onRestart = ::restartCurrentGame,
                onRevive = {
                    if (viewModel.beginReviveAttempt()) {
                        adMobManager.showRewardedAd(
                            activity = activity,
                            onRewardEarned = viewModel::continueAfterRevive,
                            onAdUnavailable = {
                                viewModel.reviveFailed("Wiederbeleben hat nicht geklappt. Bitte versuche es erneut oder beende den Run.")
                            }
                        )
                    }
                },
                onEndRun = ::finishRunAfterInterstitial,
                onExit = {
                    screen = AppScreen.Home
                }
            )

            AppScreen.Stats -> StatsScreen(
                stats = state.stats,
                topSubcategories = viewModel.topSubCategoryStats(state.stats),
                onBack = { screen = AppScreen.Home }
            )

            AppScreen.Settings -> SettingsScreen(
                soundEnabled = soundEnabled,
                hapticsEnabled = hapticsEnabled,
                onSoundChanged = { soundEnabled = it },
                onHapticsChanged = { hapticsEnabled = it },
                onOpenPrivacy = { screen = AppScreen.Privacy },
                onOpenImprint = { screen = AppScreen.Imprint },
                onBack = { screen = AppScreen.Home }
            )

            AppScreen.Privacy -> LegalInfoScreen(
                title = "Datenschutz",
                body = "Platzhalter: Hier wird vor Veröffentlichung die vollständige Datenschutzerklärung ergänzt. Sie beschreibt, welche Daten verarbeitet werden, wie Werbung eingebunden ist und wie Nutzer Kontakt aufnehmen können.",
                onBack = { screen = AppScreen.Settings }
            )

            AppScreen.Imprint -> LegalInfoScreen(
                title = "Impressum",
                body = "Platzhalter: Anbietername, Anschrift, Kontakt-E-Mail und vertretungsberechtigte Person vor dem Play-Store-Release ergänzen.",
                onBack = { screen = AppScreen.Settings }
            )
        }
    }
}
