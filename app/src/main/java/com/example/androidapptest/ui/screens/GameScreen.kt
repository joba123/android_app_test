package com.example.androidapptest.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.animateIntAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.animation.using
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
    isRewardedAdReady: Boolean,
    hapticsEnabled: Boolean,
    onBack: () -> Unit,
    onGuess: (Guess) -> Unit,
    onNextRound: () -> Unit,
    onRestart: () -> Unit,
    onContinueWithAd: () -> Unit,
    onShowGameOverStats: () -> Unit
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


    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onBack) {
                    Text("←", style = MaterialTheme.typography.titleLarge)
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
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    repeat(3) { index ->
                        Text(
                            text = "♥",
                            color = if (index < state.lives) GermanyRed else MaterialTheme.colorScheme.surfaceVariant,
                            style = MaterialTheme.typography.titleMedium
                        )
                    }
                }
            }

            AnimatedContent(
                targetState = leftItem.id to rightItem.id,
                transitionSpec = {
                    (fadeIn(tween(180)) + slideInVertically { it / 12 }) togetherWith
                        (fadeOut(tween(140)) + slideOutVertically { -it / 12 }) using
                        SizeTransform(clip = false)
                },
                label = "question transition"
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    QuizCard(
                        item = leftItem,
                        revealValue = true,
                        modifier = Modifier.fillMaxWidth(),
                        feedbackCorrect = null
                    )
                    QuizCard(
                        item = rightItem,
                        revealValue = state.isAnswerRevealed,
                        modifier = Modifier.fillMaxWidth(),
                        feedbackCorrect = state.lastAnswerCorrect
                    )
                }
            }

            AnimatedVisibility(
                visible = state.isAnswerRevealed,
                enter = fadeIn(tween(160)) + scaleIn(initialScale = 0.96f),
                exit = fadeOut(tween(120)) + scaleOut(targetScale = 0.96f)
            ) {
                FeedbackPanel(isCorrect = state.lastAnswerCorrect == true, funFact = rightItem.funFact)
            }
        }

        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            if (state.gameOver && !state.pendingGameOver) {
                GameOverDialog(
                    score = state.score,
                    isRewardedAdReady = isRewardedAdReady,
                    rewardedAdMessage = state.rewardedAdMessage,
                    isNewHighscore = state.isNewHighscore,
                    onRestart = onRestart,
                    onContinueWithAd = onContinueWithAd
                )
            }
            if (state.gameOver && state.pendingGameOver) {
                PrimaryMenuButton(text = "Nochmal spielen", onClick = onShowGameOverStats)
                OutlinedButton(onClick = onContinueWithAd, enabled = isRewardedAdReady, modifier = Modifier.fillMaxWidth()) {
                    Text("Wiederbeleben")
                }
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
    isRewardedAdReady: Boolean,
    rewardedAdMessage: String?,
    isNewHighscore: Boolean,
    onRestart: () -> Unit,
    onContinueWithAd: () -> Unit
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
                    Text(if (isNewHighscore) "Neuer Highscore!" else "Game Over", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.ExtraBold)
                    AnimatedContent(targetState = score, label = "score_anim") {
                        Text("Endscore $it", color = GermanyGold, style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.Black)
                    }
                    Text(
                        "Starte direkt neu oder sieh dir eine Rewarded Ad an, um mit 1 Leben weiterzuspielen.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                    if (!isRewardedAdReady) {
                        Text("Werbung wird geladen …", color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    rewardedAdMessage?.let { Text(it, color = GermanyGold, fontWeight = FontWeight.Bold, textAlign = TextAlign.Center) }
                    Button(onClick = onContinueWithAd, enabled = isRewardedAdReady, modifier = Modifier.fillMaxWidth()) {
                        Text("Weiter mit Werbung")
                    }
                    OutlinedButton(onClick = onRestart, modifier = Modifier.fillMaxWidth()) {
                        Text("Nochmal spielen")
                    }
                }
            }
        }
    }
}
