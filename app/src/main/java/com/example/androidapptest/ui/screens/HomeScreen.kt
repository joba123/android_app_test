package com.example.androidapptest.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.ui.components.PrimaryMenuButton
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack

@Composable
fun HomeScreen(
    categories: List<MainCategory>,
    highScoreForCategory: (MainCategory) -> Int,
    onCategorySelected: (MainCategory) -> Unit,
    onOpenStats: () -> Unit,
    onOpenSettings: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(NightBlack, GermanyRed.copy(alpha = 0.16f), NightBlack)
                )
            )
            .padding(horizontal = 20.dp)
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(top = 28.dp, bottom = 28.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            item {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "Mehr oder Weniger",
                        style = MaterialTheme.typography.displaySmall,
                        color = MaterialTheme.colorScheme.onBackground,
                        fontWeight = FontWeight.ExtraBold,
                        textAlign = TextAlign.Center
                    )
                    Text(
                        text = "Deutschland",
                        style = MaterialTheme.typography.headlineMedium,
                        color = GermanyGold,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Wähle einen Endless Run. Allgemein mischt alle Modi, vergleicht aber nur gleiche Metriken.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                    Spacer(modifier = Modifier.height(14.dp))
                }
            }

            items(categories, key = { it.id }) { category ->
                CategoryCard(
                    category = category,
                    highScore = highScoreForCategory(category),
                    onClick = { onCategorySelected(category) }
                )
            }

            item {
                Spacer(modifier = Modifier.height(8.dp))
                PrimaryMenuButton(text = "Statistiken", onClick = onOpenStats, outlined = true)
                Spacer(modifier = Modifier.height(10.dp))
                PrimaryMenuButton(text = "Einstellungen", onClick = onOpenSettings, outlined = true)
            }
        }
    }
}

@Composable
private fun CategoryCard(
    category: MainCategory,
    highScore: Int,
    onClick: () -> Unit
) {
    val borderColor = if (category.isGeneral) GermanyGold.copy(alpha = 0.58f) else GermanyRed.copy(alpha = 0.22f)
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(22.dp),
        border = BorderStroke(1.dp, borderColor),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        elevation = CardDefaults.cardElevation(defaultElevation = if (category.isGeneral) 9.dp else 5.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Text(text = category.icon, fontSize = 30.sp)
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(category.name, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.ExtraBold)
                Text(category.description, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Column(horizontalAlignment = Alignment.End) {
                Text("Highscore", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Text(highScore.toString(), style = MaterialTheme.typography.titleLarge, color = GermanyGold, fontWeight = FontWeight.Black)
            }
        }
    }
}
