package com.example.androidapptest.ui.screens

import android.content.Context
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView
import com.example.androidapptest.domain.Category
import com.example.androidapptest.domain.GameStats
import com.example.androidapptest.domain.QuizQuestion
import com.example.androidapptest.ui.GameUiState
import com.example.androidapptest.ui.GuessFeedback
import com.example.androidapptest.ui.components.cardBackground
import com.example.androidapptest.ui.components.dp
import com.example.androidapptest.ui.components.menuButton
import com.example.androidapptest.ui.components.spacer
import com.example.androidapptest.ui.components.styleText
import com.example.androidapptest.ui.components.verticalLayout
import com.example.androidapptest.ui.theme.GermanyColors

fun homeScreen(context: Context, onStart: () -> Unit, onCategories: () -> Unit, onStats: () -> Unit) =
    verticalLayout(context, 14).apply {
        setBackgroundColor(GermanyColors.Black)
        gravity = Gravity.CENTER_HORIZONTAL
        addView(spacer(context, 36))
        addView(TextView(context).apply {
            text = "Mehr oder\nWeniger"
            gravity = Gravity.CENTER
            styleText(48f, GermanyColors.White, true)
        })
        addView(TextView(context).apply {
            text = "Deutschland"
            gravity = Gravity.CENTER
            styleText(30f, GermanyColors.Gold, true)
        })
        addView(TextView(context).apply {
            text = "Higher-or-Lower mit Städten, Fußball, Autos, Alltag, Bundesländern und Unternehmen."
            gravity = Gravity.CENTER
            styleText(17f, GermanyColors.Muted)
        })
        addView(spacer(context, 44))
        addView(menuButton(context, "Endlosmodus", onClick = onStart))
        addView(menuButton(context, "Kategorien", primary = false, onClick = onCategories))
        addView(menuButton(context, "Daily Challenge · Coming soon", enabled = false, onClick = {}))
        addView(menuButton(context, "Statistiken", primary = false, onClick = onStats))
    }

fun categoryScreen(context: Context, onBack: () -> Unit, onSelect: (Category) -> Unit) =
    verticalLayout(context, 12).apply {
        setBackgroundColor(GermanyColors.Black)
        addView(header(context, "Kategorien", onBack))
        Category.entries.forEach { category ->
            addView(menuButton(context, "${category.emoji}  ${category.label}", primary = category == Category.MIXED, onClick = { onSelect(category) }))
        }
    }

fun statsScreen(context: Context, stats: GameStats, onBack: () -> Unit) =
    verticalLayout(context, 12).apply {
        setBackgroundColor(GermanyColors.Black)
        addView(header(context, "Statistiken", onBack))
        addStat(context, "Highscore", stats.highScore.toString())
        addStat(context, "Spiele gespielt", stats.gamesPlayed.toString())
        addStat(context, "Beste Streak", stats.bestStreak.toString())
        addStat(context, "Richtige Antworten", stats.correctAnswers.toString())
        addStat(context, "Falsche Antworten", stats.wrongAnswers.toString())
        addStat(context, "Genauigkeit", "${stats.accuracy} %")
    }

fun gameScreen(
    context: Context,
    state: GameUiState,
    onBack: () -> Unit,
    onHigher: () -> Unit,
    onLower: () -> Unit,
    onRestart: () -> Unit
) = verticalLayout(context, 12).apply {
    setBackgroundColor(GermanyColors.Black)
    addView(header(context, "${state.selectedCategory.emoji} ${state.selectedCategory.label}", onBack))
    addView(TextView(context).apply {
        text = "Score ${state.score}    Streak ${state.streak}    ${"♥".repeat(state.lives).ifBlank { "♡" }}"
        gravity = Gravity.CENTER
        styleText(22f, GermanyColors.Gold, true)
    })
    addView(questionCard(context, "Bekannt", state.leftQuestion, true, null))
    addView(questionCard(context, "Mehr oder weniger?", state.rightQuestion, state.isRevealed, state.feedback))
    addView(TextView(context).apply {
        text = when {
            state.gameOver -> "Game Over! Dein Score: ${state.score}"
            state.feedback == GuessFeedback.CORRECT -> "Richtig! Weiter geht's …"
            state.feedback == GuessFeedback.WRONG -> "Leider falsch. Nächste Chance …"
            else -> "Ist der verdeckte Wert höher oder weniger?"
        }
        gravity = Gravity.CENTER
        styleText(18f, if (state.feedback == GuessFeedback.CORRECT) GermanyColors.Green else if (state.feedback == GuessFeedback.WRONG || state.gameOver) GermanyColors.Red else GermanyColors.Muted, true)
    })
    if (state.gameOver) {
        addView(menuButton(context, "Nochmal spielen", onClick = onRestart))
        addView(menuButton(context, "Zur Startseite", primary = false, onClick = onBack))
    } else {
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            val higher = menuButton(context, "Höher", enabled = !state.isRoundLocked, onClick = onHigher)
            val lower = menuButton(context, "Weniger", primary = false, enabled = !state.isRoundLocked, onClick = onLower)
            higher.layoutParams = LinearLayout.LayoutParams(0, context.dp(62), 1f).apply { rightMargin = context.dp(7) }
            lower.layoutParams = LinearLayout.LayoutParams(0, context.dp(62), 1f).apply { leftMargin = context.dp(7) }
            addView(higher)
            addView(lower)
        })
    }
}

private fun header(context: Context, title: String, onBack: () -> Unit) = LinearLayout(context).apply {
    orientation = LinearLayout.HORIZONTAL
    gravity = Gravity.CENTER_VERTICAL
    addView(menuButton(context, "‹", primary = false, onClick = onBack).apply {
        layoutParams = LinearLayout.LayoutParams(context.dp(58), context.dp(50))
        textSize = 28f
    })
    addView(TextView(context).apply {
        text = title
        styleText(26f, GermanyColors.White, true)
        setPadding(context.dp(14), 0, 0, 0)
        layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
    })
}

private fun LinearLayout.addStat(context: Context, label: String, value: String) {
    addView(TextView(context).apply {
        text = "$label\n$value"
        styleText(22f, GermanyColors.Gold, true)
        setPadding(context.dp(18), context.dp(16), context.dp(18), context.dp(16))
        background = cardBackground(GermanyColors.SurfaceLight, GermanyColors.Gold)
        layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
    })
}

private fun questionCard(context: Context, title: String, question: QuizQuestion?, revealed: Boolean, feedback: GuessFeedback?) =
    TextView(context).apply {
        val value = if (revealed) question?.formattedValue.orEmpty() else "?"
        text = "$title\n${question?.title.orEmpty()}\n${question?.subtitle.orEmpty()}\n$value"
        gravity = Gravity.CENTER
        styleText(if (revealed) 24f else 32f, GermanyColors.White, true)
        setPadding(context.dp(18), context.dp(18), context.dp(18), context.dp(18))
        val color = when (feedback) {
            GuessFeedback.CORRECT -> 0xFF123B28.toInt()
            GuessFeedback.WRONG -> 0xFF3A1118.toInt()
            null -> GermanyColors.Surface
        }
        background = cardBackground(color, GermanyColors.Gold)
        layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, context.dp(190))
    }
