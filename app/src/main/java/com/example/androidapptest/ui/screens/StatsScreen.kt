package com.example.androidapptest.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.androidapptest.domain.Stats
import com.example.androidapptest.ui.components.StatTile

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun StatsScreen(stats: Stats, onBack: () -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(20.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Zurück")
            }
            Text(
                text = "Statistiken",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.ExtraBold
            )
        }
        FlowRow(
            modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            maxItemsInEachRow = 2
        ) {
            StatTile("Highscore", stats.highScore.toString(), Modifier.weight(1f))
            StatTile("Spiele gespielt", stats.gamesPlayed.toString(), Modifier.weight(1f))
            StatTile("Beste Streak", stats.bestStreak.toString(), Modifier.weight(1f))
            StatTile("Richtige Antworten", stats.correctAnswers.toString(), Modifier.weight(1f))
            StatTile("Falsche Antworten", stats.wrongAnswers.toString(), Modifier.weight(1f))
            StatTile("Genauigkeit", "${stats.accuracy}%", Modifier.weight(1f))
        }
    }
}
