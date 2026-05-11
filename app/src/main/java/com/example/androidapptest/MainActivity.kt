package com.example.androidapptest

import android.app.Activity
import android.os.Bundle
import android.widget.FrameLayout
import com.example.androidapptest.ui.AppScreen
import com.example.androidapptest.ui.GameUiState
import com.example.androidapptest.ui.GameViewModel
import com.example.androidapptest.ui.screens.categoryScreen
import com.example.androidapptest.ui.screens.gameScreen
import com.example.androidapptest.ui.screens.homeScreen
import com.example.androidapptest.ui.screens.statsScreen

class MainActivity : Activity() {
    private lateinit var container: FrameLayout
    private lateinit var viewModel: GameViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = 0xFF090909.toInt()
        window.navigationBarColor = 0xFF090909.toInt()
        container = FrameLayout(this)
        viewModel = GameViewModel(this)
        setContentView(container)
        viewModel.observe(::render)
    }

    private fun render(state: GameUiState) {
        val nextView = when (state.screen) {
            AppScreen.HOME -> homeScreen(
                context = this,
                onStart = { viewModel.startGame() },
                onCategories = viewModel::showCategories,
                onStats = viewModel::showStats
            )
            AppScreen.CATEGORIES -> categoryScreen(
                context = this,
                onBack = viewModel::showHome,
                onSelect = viewModel::startGame
            )
            AppScreen.GAME -> gameScreen(
                context = this,
                state = state,
                onBack = viewModel::showHome,
                onHigher = viewModel::guessHigher,
                onLower = viewModel::guessLower,
                onRestart = viewModel::restartCurrentGame
            )
            AppScreen.STATS -> statsScreen(
                context = this,
                stats = viewModel.stats,
                onBack = viewModel::showHome
            )
        }
        container.removeAllViews()
        container.addView(nextView)
    }
}
