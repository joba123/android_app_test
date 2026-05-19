package com.example.androidapptest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.androidapptest.ads.AdMobManager
import com.example.androidapptest.data.StatsRepository
import com.example.androidapptest.domain.QuizCategory
import com.example.androidapptest.ui.GameViewModel
import com.example.androidapptest.ui.screens.CategoryScreen
import com.example.androidapptest.ui.screens.GameScreen
import com.example.androidapptest.ui.screens.HomeScreen
import com.example.androidapptest.ui.screens.LegalInfoScreen
import com.example.androidapptest.ui.screens.SettingsScreen
import com.example.androidapptest.ui.screens.StatsScreen
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
    MainMenu,
    Home,
    Game,
    Categories,
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
    val isRewardedAdReady by adMobManager.isRewardedAdReady.collectAsStateWithLifecycle()
    var screen by remember { mutableStateOf(AppScreen.MainMenu) }
    var interstitialShownForGameOver by remember { mutableStateOf(false) }
    var soundEnabled by rememberSaveable { mutableStateOf(false) }
    var hapticsEnabled by rememberSaveable { mutableStateOf(true) }

    fun openGame(category: QuizCategory) {
        interstitialShownForGameOver = false
        viewModel.startGame(category)
        screen = AppScreen.Game
    }

    LaunchedEffect(state.gameOver, screen) {
        if (screen == AppScreen.Game && state.gameOver && !interstitialShownForGameOver) {
            interstitialShownForGameOver = true
            adMobManager.showInterstitialAfterGameOver(activity)
        }
        if (!state.gameOver) {
            interstitialShownForGameOver = false
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        when (screen) {
            AppScreen.MainMenu -> HomeScreen(
                onPlay = { screen = AppScreen.Home },
                onOpenStats = { screen = AppScreen.Stats },
                onOpenSettings = { screen = AppScreen.Settings }
            )

            AppScreen.Home -> CategoryScreen(
                categories = viewModel.categories,
                onBack = { screen = AppScreen.MainMenu },
                onCategorySelected = { openGame(it) }
            )

            AppScreen.Game -> GameScreen(
                state = state,
                isRewardedAdReady = isRewardedAdReady,
                onBack = {
                    viewModel.finishGameFromNavigation()
                    screen = AppScreen.MainMenu
                },
                hapticsEnabled = hapticsEnabled,
                onGuess = viewModel::submitGuess,
                onNextRound = viewModel::nextRound,
                onRestart = { openGame(state.category) },
                onContinueWithAd = {
                    adMobManager.showRewardedAd(
                        activity = activity,
                        onRewardEarned = viewModel::continueAfterRewardedAd,
                        onAdUnavailable = viewModel::markRewardedAdUnavailable
                    )
                },
                onShowGameOverStats = viewModel::showGameOverStats
            )

            AppScreen.Stats -> StatsScreen(
                stats = state.stats,
                onBack = { screen = AppScreen.MainMenu }
            )

            AppScreen.Settings -> SettingsScreen(
                soundEnabled = soundEnabled,
                hapticsEnabled = hapticsEnabled,
                onSoundChanged = { soundEnabled = it },
                onHapticsChanged = { hapticsEnabled = it },
                onOpenPrivacy = { screen = AppScreen.Privacy },
                onOpenImprint = { screen = AppScreen.Imprint },
                onBack = { screen = AppScreen.MainMenu }
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
