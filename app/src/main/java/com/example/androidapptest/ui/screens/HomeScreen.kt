package com.example.androidapptest.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.androidapptest.ui.components.PrimaryMenuButton
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack

@Composable
fun HomeScreen(
    onPlay: () -> Unit,
    onOpenStats: () -> Unit,
    onOpenSettings: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(colors = listOf(NightBlack, GermanyRed.copy(alpha = 0.16f), NightBlack)))
            .padding(horizontal = 24.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
            Text("Mehr oder Weniger", style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.ExtraBold)
            Text("Deutschland", style = MaterialTheme.typography.headlineMedium, color = GermanyGold, fontWeight = FontWeight.Bold)
            Text(
                "Teste dein Wissen in verschiedenen Kategorien.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 10.dp, bottom = 24.dp)
            )
            PrimaryMenuButton(text = "Spielen", onClick = onPlay)
            Spacer(modifier = Modifier.height(12.dp))
            PrimaryMenuButton(text = "Statistiken", onClick = onOpenStats, outlined = true)
            Spacer(modifier = Modifier.height(10.dp))
            PrimaryMenuButton(text = "Einstellungen", onClick = onOpenSettings, outlined = true)
        }
    }
}
