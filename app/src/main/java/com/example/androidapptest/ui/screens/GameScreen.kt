package com.example.androidapptest.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateIntAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.example.androidapptest.domain.GameUiState
import com.example.androidapptest.domain.Guess
import com.example.androidapptest.ui.components.PrimaryMenuButton
import com.example.androidapptest.ui.components.QuizCard
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack
import com.example.androidapptest.ui.theme.SuccessGreen

@Composable
fun GameScreen(
    state: GameUiState,
    hapticsEnabled: Boolean,
    onBack: () -> Unit,
    onGuess: (Guess) -> Unit,
    onNextRound: () -> Unit,
    onRestart: () -> Unit
) {
    val leftItem = state.leftItem ?: return
    val rightItem = state.rightItem ?: return
    val haptic = LocalHapticFeedback.current
    val animatedScore by animateIntAsState(targetValue = state.score, label = "score counter")

    LaunchedEffect(state.isAnswerRevealed, state.lastAnswerCorrect, hapticsEnabled) {
        if (hapticsEnabled && state.isAnswerRevealed && state.lastAnswerCorrect != null) {
            haptic.performHapticFeedback(
                if (state.lastAnswerCorrect == true) HapticFeedbackType.TextHandleMove else HapticFeedbackType.LongPress
            )
        }
    }

    if (state.gameOver) {
        GameOverDialog(
            score = state.score,
            onRestart = onRestart
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onBack) {
                    Text("←", style = MaterialTheme.typography.titleLarge, color = MaterialTheme.colorScheme.onBackground)
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text(text = state.category.title, style = MaterialTheme.typography.titleMedium, color = GermanyGold)
                    AnimatedContent(targetState = animatedScore, label = "animated score") { score ->
                        Text(
                            text = "Score $score · Streak ${state.streak}",
                            style = MaterialTheme.typography.headlineSmall,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                }
            }

            AnimatedContent(
                targetState = leftItem to rightItem,
                transitionSpec = {
                    (fadeIn(tween(180)) + slideInVertically { it / 12 }) togetherWith
                        (fadeOut(tween(140)) + slideOutVertically { -it / 12 })
                },
                label = "question transition"
            ) { (animatedLeftItem, animatedRightItem) ->
                Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    QuizCard(
                        item = animatedLeftItem,
                        revealValue = true,
                        modifier = Modifier.fillMaxWidth(),
                        feedbackCorrect = null
                    )
                    QuizCard(
                        item = animatedRightItem,
                        revealValue = state.isAnswerRevealed,
                        modifier = Modifier.fillMaxWidth(),
                        feedbackCorrect = state.lastAnswerCorrect
                    )
                }
            }

            AnimatedVisibility(
                visible = state.isAnswerRevealed && state.lastAnswerCorrect != null,
                enter = fadeIn(tween(160)) + scaleIn(initialScale = 0.96f),
                exit = fadeOut(tween(120)) + scaleOut(targetScale = 0.96f)
            ) {
                state.lastAnswerCorrect?.let { isCorrect ->
                    FeedbackPanel(isCorrect = isCorrect, funFact = rightItem.funFact)
                }
            }
        }

        Column(
            modifier = Modifier
                .navigationBarsPadding()
                .padding(bottom = 24.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            if (state.gameOver) {
                Text(
                    text = "Game Over · Endscore ${state.score}",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.ExtraBold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
                PrimaryMenuButton(text = "Nochmal spielen", onClick = onRestart)
            } else if (state.isAnswerRevealed) {
                PrimaryMenuButton(text = "Nächste Frage", onClick = onNextRound)
            } else {
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    Button(
                        onClick = { onGuess(Guess.Higher) },
                        colors = ButtonDefaults.buttonColors(containerColor = GermanyGold, contentColor = MaterialTheme.colorScheme.onPrimary),
                        modifier = Modifier.weight(1f)
                    ) { Text("Höher", fontWeight = FontWeight.Bold) }
                    OutlinedButton(
                        onClick = { onGuess(Guess.Lower) },
                        modifier = Modifier.weight(1f)
                    ) { Text("Weniger", fontWeight = FontWeight.Bold) }
                }
            }
            Spacer(modifier = Modifier.height(4.dp))
        }
    }
}

@Composable
private fun FeedbackPanel(isCorrect: Boolean, funFact: String) {
    val accent = if (isCorrect) SuccessGreen else GermanyRed
    Card(
        shape = RoundedCornerShape(22.dp),
        border = BorderStroke(1.dp, accent.copy(alpha = 0.45f)),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text(
                text = if (isCorrect) "Richtig!" else "Leider falsch",
                color = accent,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.ExtraBold,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
            Text(
                text = "Fun Fact: $funFact",
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

@Composable
private fun GameOverDialog(
    score: Int,
    onRestart: () -> Unit
) {
    Dialog(onDismissRequest = {}) {
        Card(
            shape = RoundedCornerShape(30.dp),
            border = BorderStroke(1.dp, GermanyGold.copy(alpha = 0.42f)),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            elevation = CardDefaults.cardElevation(defaultElevation = 18.dp)
        ) {
            Box(
                modifier = Modifier.background(
                    Brush.verticalGradient(
                        listOf(GermanyGold.copy(alpha = 0.18f), NightBlack.copy(alpha = 0.08f))
                    )
                )
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("Game Over", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.ExtraBold)
                    Text("Endscore $score", color = GermanyGold, style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.Black)
                    Text(
                        "Eine falsche Antwort beendet den Run. Starte neu und versuche, deine Serie zu schlagen.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                    OutlinedButton(onClick = onRestart, modifier = Modifier.fillMaxWidth()) {
                        Text("Nochmal spielen")
                    }
                }
            }
        }
    }
}
