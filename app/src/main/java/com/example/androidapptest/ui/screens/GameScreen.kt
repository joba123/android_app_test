package com.example.androidapptest.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.androidapptest.domain.GameUiState
import com.example.androidapptest.domain.Guess
import com.example.androidapptest.ui.components.PrimaryMenuButton
import com.example.androidapptest.ui.components.QuizCard
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.SuccessGreen

@Composable
fun GameScreen(
    state: GameUiState,
    onBack: () -> Unit,
    onGuess: (Guess) -> Unit,
    onNextRound: () -> Unit,
    onRestart: () -> Unit
) {
    val leftItem = state.leftItem ?: return
    val rightItem = state.rightItem ?: return

    Column(
        modifier = Modifier.fillMaxSize().padding(20.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onBack) {
                    Text("←", style = MaterialTheme.typography.titleLarge)
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text(text = state.category.title, style = MaterialTheme.typography.titleMedium, color = GermanyGold)
                    Text(
                        text = "Score ${state.score} · Streak ${state.streak}",
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.ExtraBold
                    )
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

            AnimatedVisibility(visible = state.isAnswerRevealed) {
                Text(
                    text = if (state.lastAnswerCorrect == true) "Richtig! Der nächste Vergleich wartet." else "Leider falsch – merke dir den Wert für später.",
                    color = if (state.lastAnswerCorrect == true) SuccessGreen else GermanyRed,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
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
