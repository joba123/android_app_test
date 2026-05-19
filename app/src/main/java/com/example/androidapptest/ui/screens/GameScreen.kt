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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.domain.game.GameUiState
import com.example.androidapptest.domain.game.Guess
import com.example.androidapptest.domain.game.RunStatus
import com.example.androidapptest.ui.components.QuizCard
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack
import com.example.androidapptest.ui.theme.SuccessGreen
import kotlinx.coroutines.delay

@Composable
fun GameScreen(
    state: GameUiState,
    hapticsEnabled: Boolean,
    onBack: () -> Unit,
    onGuess: (Guess) -> Unit,
    onNextRound: () -> Unit,
    onRestart: () -> Unit,
    onRevive: () -> Unit,
    onEndRun: () -> Unit,
    onExit: () -> Unit
) {
    val referenceItem = state.referenceItem ?: return
    val comparisonItem = state.comparisonItem ?: return
    val haptic = LocalHapticFeedback.current
    val animatedScore by animateIntAsState(targetValue = state.score, label = "score counter")

    LaunchedEffect(state.isAnswerRevealed, state.lastAnswerCorrect, hapticsEnabled) {
        if (hapticsEnabled && state.isAnswerRevealed && state.lastAnswerCorrect != null) {
            haptic.performHapticFeedback(
                if (state.lastAnswerCorrect == true) HapticFeedbackType.TextHandleMove else HapticFeedbackType.LongPress
            )
        }
    }

    LaunchedEffect(state.isAnswerRevealed, state.lastAnswerCorrect, state.runStatus, comparisonItem.id) {
        if (state.isAnswerRevealed && state.lastAnswerCorrect == true && state.runStatus == RunStatus.Playing) {
            delay(850)
            onNextRound()
        }
    }

    when (state.runStatus) {
        RunStatus.LostButCanRevive,
        RunStatus.Reviving -> ReviveDialog(
            score = state.score,
            answerText = "${comparisonItem.title}: ${comparisonItem.displayValue}",
            errorMessage = state.reviveErrorMessage,
            isReviving = state.runStatus == RunStatus.Reviving,
            onRevive = onRevive,
            onEndRun = onEndRun
        )

        RunStatus.GameOver -> GameOverDialog(
            score = state.score,
            previousHighScore = state.previousHighScore,
            currentHighScore = state.currentHighScore,
            answerText = "${comparisonItem.title}: ${comparisonItem.displayValue}",
            isNewHighScore = state.isNewHighScore,
            onRestart = onRestart,
            onExit = onExit
        )

        RunStatus.Playing -> Unit
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
                    Text(text = state.mode.displayTitle, style = MaterialTheme.typography.titleMedium, color = GermanyGold)
                    Text(
                        text = state.mode.displaySubtitle,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    AnimatedContent(targetState = animatedScore, label = "animated score") { score ->
                        Text(
                            text = "Score $score · Highscore ${state.currentHighScore}",
                            style = MaterialTheme.typography.headlineSmall,
                            color = Color.White,
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                    Text(
                        text = "Streak ${state.streak} · ${comparisonItem.categoryName} · ${comparisonItem.subcategoryName}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            AnimatedContent(
                targetState = referenceItem to comparisonItem,
                transitionSpec = {
                    (fadeIn(tween(220)) + slideInVertically { it / 5 }) togetherWith
                        (fadeOut(tween(180)) + slideOutVertically { -it / 4 })
                },
                label = "question transition"
            ) { (animatedReferenceItem, animatedComparisonItem) ->
                Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    QuizCard(
                        item = animatedReferenceItem,
                        roleLabel = "Referenz",
                        revealValue = true,
                        modifier = Modifier.fillMaxWidth(),
                        feedbackCorrect = null
                    )
                    QuizCard(
                        item = animatedComparisonItem,
                        roleLabel = "Vergleich",
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
                    FeedbackPanel(isCorrect = isCorrect, item = comparisonItem)
                }
            }
        }

        Column(
            modifier = Modifier
                .navigationBarsPadding()
                .padding(bottom = 24.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            if (state.runStatus == RunStatus.GameOver) {
                Text(
                    text = "Game Over · Endscore ${state.score}",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.ExtraBold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            } else if (state.runStatus == RunStatus.LostButCanRevive || state.runStatus == RunStatus.Reviving) {
                Text(
                    text = if (state.runStatus == RunStatus.Reviving) {
                        "Wiederbelebung läuft..."
                    } else {
                        "Run pausiert"
                    },
                    color = GermanyGold,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.ExtraBold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            } else if (state.isAnswerRevealed && state.lastAnswerCorrect == true) {
                Text(
                    text = "Richtig! Nächste Karte kommt...",
                    color = SuccessGreen,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.ExtraBold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
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
                    ) { Text("Niedriger", fontWeight = FontWeight.Bold) }
                }
            }
            Spacer(modifier = Modifier.height(4.dp))
        }
    }
}

@Composable
private fun FeedbackPanel(isCorrect: Boolean, item: ComparisonItem) {
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
                text = if (isCorrect) {
                    "Fun Fact: ${item.funFact.orEmpty()}"
                } else {
                    "Richtige Lösung: ${item.title} · ${item.displayValue}"
                },
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

@Composable
private fun ReviveDialog(
    score: Int,
    answerText: String,
    errorMessage: String?,
    isReviving: Boolean,
    onRevive: () -> Unit,
    onEndRun: () -> Unit
) {
    Dialog(onDismissRequest = {}) {
        Card(
            shape = RoundedCornerShape(30.dp),
            border = BorderStroke(1.dp, GermanyRed.copy(alpha = 0.42f)),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            elevation = CardDefaults.cardElevation(defaultElevation = 18.dp)
        ) {
            Box(
                modifier = Modifier.background(
                    Brush.verticalGradient(
                        listOf(GermanyRed.copy(alpha = 0.16f), NightBlack.copy(alpha = 0.08f))
                    )
                )
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("Du hast verloren.", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.ExtraBold)
                    Text(
                        "Möchtest du dich wiederbeleben?",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                    Text("Score $score", color = GermanyGold, style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Black)
                    Text(
                        "Richtige Lösung: $answerText",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                    if (errorMessage != null) {
                        Text(
                            errorMessage,
                            color = GermanyRed,
                            textAlign = TextAlign.Center,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Button(
                        onClick = onRevive,
                        enabled = !isReviving,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = GermanyGold,
                            contentColor = MaterialTheme.colorScheme.onPrimary
                        )
                    ) {
                        Text(if (isReviving) "Ad läuft..." else "Wiederbeleben")
                    }
                    OutlinedButton(onClick = onEndRun, enabled = !isReviving, modifier = Modifier.fillMaxWidth()) {
                        Text("Nein, beenden")
                    }
                }
            }
        }
    }
}

@Composable
private fun GameOverDialog(
    score: Int,
    previousHighScore: Int,
    currentHighScore: Int,
    answerText: String,
    isNewHighScore: Boolean,
    onRestart: () -> Unit,
    onExit: () -> Unit
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
                        if (isNewHighScore) {
                            "Neuer Highscore: $currentHighScore"
                        } else {
                            "Highscore: $currentHighScore"
                        },
                        color = if (isNewHighScore) SuccessGreen else MaterialTheme.colorScheme.onSurfaceVariant,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.ExtraBold,
                        textAlign = TextAlign.Center
                    )
                    if (isNewHighScore) {
                        Text(
                            "Bisheriger Highscore: $previousHighScore",
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = TextAlign.Center
                        )
                    }
                    Text(
                        "Richtige Lösung: $answerText",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center
                    )
                    AnimatedVisibility(visible = isNewHighScore, enter = scaleIn(), exit = scaleOut()) {
                        Text("Neuer Highscore!", color = SuccessGreen, fontWeight = FontWeight.ExtraBold)
                    }
                    OutlinedButton(onClick = onRestart, modifier = Modifier.fillMaxWidth()) {
                        Text("Nochmal spielen")
                    }
                    OutlinedButton(onClick = onExit, modifier = Modifier.fillMaxWidth()) {
                        Text("Zurück zum Menü")
                    }
                }
            }
        }
    }
}
