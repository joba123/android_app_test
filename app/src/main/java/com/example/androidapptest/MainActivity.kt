package com.example.androidapptest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
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
import com.example.androidapptest.ui.screens.StatsScreen
import com.example.androidapptest.ui.theme.DeutschlandQuizTheme

class MainActivity : ComponentActivity() {
    private lateinit var adMobManager: AdMobManager

    override fun onCreate(savedInstanceState: Bundle?) {
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
    Game,
    Categories,
    Stats
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
    var screen by remember { mutableStateOf(AppScreen.Home) }
    var interstitialShownForGameOver by remember { mutableStateOf(false) }

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
            AppScreen.Home -> HomeScreen(
                onStartEndless = { openGame(QuizCategory.Mixed) },
                onOpenCategories = { screen = AppScreen.Categories },
                onOpenStats = { screen = AppScreen.Stats }
            )

            AppScreen.Game -> GameScreen(
                state = state,
                isRewardedAdReady = isRewardedAdReady,
                onBack = {
                    viewModel.finishGameFromNavigation()
                    screen = AppScreen.Home
                },
                onGuess = viewModel::submitGuess,
                onNextRound = viewModel::nextRound,
                onRestart = { openGame(state.category) },
                onContinueWithAd = {
                    adMobManager.showRewardedAd(
                        activity = activity,
                        onRewardEarned = viewModel::continueAfterRewardedAd,
                        onAdUnavailable = viewModel::markRewardedAdUnavailable
                    )
                }
            )

            AppScreen.Categories -> CategoryScreen(
                categories = viewModel.categories,
                onBack = { screen = AppScreen.Home },
                onCategorySelected = { openGame(it) }
            )

            AppScreen.Stats -> StatsScreen(
                stats = state.stats,
                onBack = { screen = AppScreen.Home }
            )
        }
    }
}
