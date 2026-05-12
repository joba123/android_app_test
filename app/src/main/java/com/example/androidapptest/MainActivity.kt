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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.androidapptest.domain.QuizCategory
import com.example.androidapptest.ui.GameViewModel
import com.example.androidapptest.ui.screens.CategoryScreen
import com.example.androidapptest.ui.screens.GameScreen
import com.example.androidapptest.ui.screens.HomeScreen
import com.example.androidapptest.ui.screens.StatsScreen
import com.example.androidapptest.ui.theme.DeutschlandQuizTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            DeutschlandQuizTheme {
                DeutschlandQuizApp()
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
private fun DeutschlandQuizApp(viewModel: GameViewModel = viewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    var screen by remember { mutableStateOf(AppScreen.Home) }

    fun openGame(category: QuizCategory) {
        viewModel.startGame(category)
        screen = AppScreen.Game
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
                onBack = {
                    viewModel.finishGameFromNavigation()
                    screen = AppScreen.Home
                },
                onGuess = viewModel::submitGuess,
                onNextRound = viewModel::nextRound,
                onRestart = { viewModel.startGame(state.category) }
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
