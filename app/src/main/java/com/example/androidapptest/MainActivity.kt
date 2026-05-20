package com.example.androidapptest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
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
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack

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

@Composable
private fun ExitGameDialog(
    onContinue: () -> Unit,
    onEndRun: () -> Unit
) {
    Dialog(onDismissRequest = onContinue) {
        Card(
            shape = RoundedCornerShape(30.dp),
            border = BorderStroke(1.dp, GermanyGold.copy(alpha = 0.42f)),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            elevation = CardDefaults.cardElevation(defaultElevation = 18.dp)
        ) {
            Box(
                modifier = Modifier.background(
                    Brush.verticalGradient(
                        listOf(
                            GermanyGold.copy(alpha = 0.16f),
                            GermanyRed.copy(alpha = 0.08f),
                            NightBlack.copy(alpha = 0.10f)
                        )
                    )
                )
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Runde beenden?",
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.ExtraBold,
                        textAlign = TextAlign.Center
                    )
                    Text(
                        text = "Wenn du jetzt zurückgehst, wird die laufende Runde abgebrochen und dein aktueller Score geht verloren.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        style = MaterialTheme.typography.bodyMedium,
                        textAlign = TextAlign.Center
                    )
                    Button(
                        onClick = onContinue,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = GermanyGold,
                            contentColor = MaterialTheme.colorScheme.onPrimary
                        )
                    ) {
                        Text("Weiterspielen", fontWeight = FontWeight.Bold)
                    }
                    OutlinedButton(
                        onClick = onEndRun,
                        modifier = Modifier.fillMaxWidth(),
                        border = BorderStroke(1.dp, GermanyRed.copy(alpha = 0.62f)),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = GermanyRed)
                    ) {
                        Text("Runde beenden", fontWeight = FontWeight.Bold)
                    }
                }
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
    var finishedRunCount by rememberSaveable { mutableStateOf(0) }
    var showExitGameDialog by remember { mutableStateOf(false) }
    val categoryPreviewImages = remember(viewModel) { viewModel.previewImagesForMainCategories() }

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

        finishedRunCount += 1
        // Interstitial nur jede zweite Runde und nur wenn der Score über 3 war.
        val shouldShowInterstitial = state.score > 3 && finishedRunCount % 2 == 0
        if (shouldShowInterstitial) {
            interstitialShownForGameOver = true
            adMobManager.showInterstitialAfterGameOver(activity, onFinished = { finishRun() })
        } else {
            finishRun()
        }
    }

    fun navigateBack() {
        when (screen) {
            AppScreen.Home -> Unit
            AppScreen.Game -> {
                when (state.runStatus) {
                    RunStatus.LostButCanRevive,
                    RunStatus.Reviving -> finishRunAfterInterstitial()
                    RunStatus.GameOver -> {
                        viewModel.finishGameFromNavigation()
                        screen = gameReturnScreen
                    }
                    RunStatus.Playing -> showExitGameDialog = true
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
                overallHighScore = state.stats.overallHighScore,
                lastModeLabel = state.stats.selectedModeLabel,
                highScoreForCategory = { viewModel.highScoreForMainCategory(it, state.stats) },
                itemCountForCategory = viewModel::itemCountForMainCategory,
                previewImagesByCategoryId = categoryPreviewImages,
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
                previewImagesByCategoryId = categoryPreviewImages,
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
                    val subCategories = viewModel.subCategoriesFor(selectedCategory.id)
                    val subCategoryPreviewImages = remember(selectedCategory.id) {
                        viewModel.previewImagesForSubCategories(selectedCategory.id)
                    }
                    SubCategoryScreen(
                        category = selectedCategory,
                        subCategories = subCategories,
                        summaryFor = { subCategory ->
                            viewModel.subCategorySummaries(selectedCategory.id, state.stats)
                                .first { it.key == subCategory.modeKey }
                        },
                        itemCountFor = { viewModel.itemCount(it.categoryId, it.id) },
                        previewImagesByModeKey = subCategoryPreviewImages,
                        onBack = { screen = AppScreen.Categories },
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

        if (showExitGameDialog) {
            ExitGameDialog(
                onContinue = { showExitGameDialog = false },
                onEndRun = {
                    showExitGameDialog = false
                    interstitialShownForGameOver = false
                    endingRun = false
                    viewModel.abandonRunFromNavigation()
                    screen = gameReturnScreen
                }
            )
        }
    }
}
