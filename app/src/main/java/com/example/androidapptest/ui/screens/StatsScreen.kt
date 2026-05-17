package com.example.androidapptest.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.androidapptest.domain.stats.ModeStatSummary
import com.example.androidapptest.domain.stats.Stats
import com.example.androidapptest.ui.components.StatTile
import com.example.androidapptest.ui.theme.GermanyGold

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun StatsScreen(
    stats: Stats,
    topSubcategories: List<ModeStatSummary>,
    onBack: () -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onBack) {
                    Text("←", style = MaterialTheme.typography.titleLarge, color = MaterialTheme.colorScheme.onBackground)
                }
                Text(
                    text = "Statistiken",
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.onBackground,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        }

        item {
            if (stats.gamesPlayed == 0 && stats.correctAnswers == 0 && stats.wrongAnswers == 0) {
                Text(
                    text = "Noch keine Spiele",
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                maxItemsInEachRow = 2
            ) {
                StatTile("Highscore Allgemein", stats.generalHighScore.toString(), Modifier.weight(1f))
                StatTile("Bester Run", stats.overallHighScore.toString(), Modifier.weight(1f))
                StatTile("Spiele gespielt", stats.gamesPlayed.toString(), Modifier.weight(1f))
                StatTile("Beste Streak", stats.bestStreak.toString(), Modifier.weight(1f))
                StatTile(
                    label = "Beste Unterkategorie: ${topSubcategories.firstOrNull()?.title ?: "Noch keine"}",
                    value = topSubcategories.firstOrNull()?.highScore?.toString() ?: "0",
                    modifier = Modifier.weight(1f)
                )
                StatTile("Richtige Antworten", stats.correctAnswers.toString(), Modifier.weight(1f))
                StatTile("Genauigkeit", "${stats.accuracy}%", Modifier.weight(1f))
            }
        }

        item {
            Text(
                text = "Top-Unterkategorien",
                style = MaterialTheme.typography.titleLarge,
                color = GermanyGold,
                fontWeight = FontWeight.ExtraBold
            )
        }

        if (topSubcategories.isEmpty()) {
            item {
                Text(
                    text = "Noch keine Unterkategorie-Highscores.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        } else {
            items(topSubcategories, key = { it.key }) { summary ->
                StatTile(
                    label = "${summary.title} · Streak ${summary.bestStreak}",
                    value = summary.highScore.toString(),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}
