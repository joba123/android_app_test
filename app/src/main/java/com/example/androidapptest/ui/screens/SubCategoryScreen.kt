package com.example.androidapptest.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.data.model.SubCategory
import com.example.androidapptest.domain.stats.ModeStatSummary
import com.example.androidapptest.ui.theme.GermanyGold

@Composable
fun SubCategoryScreen(
    category: MainCategory,
    subCategories: List<SubCategory>,
    summaryFor: (SubCategory) -> ModeStatSummary,
    itemCountFor: (SubCategory) -> Int,
    onBack: () -> Unit,
    onSubCategorySelected: (SubCategory) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = onBack) {
                Text("←", style = MaterialTheme.typography.titleLarge, color = MaterialTheme.colorScheme.onBackground)
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = category.name,
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.onBackground,
                    fontWeight = FontWeight.ExtraBold
                )
                Text(
                    text = "Unterkategorie wählen",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            items(subCategories, key = { it.modeKey }) { subCategory ->
                val summary = summaryFor(subCategory)
                val itemCount = itemCountFor(subCategory)
                SubCategoryCard(
                    subCategory = subCategory,
                    summary = summary,
                    itemCount = itemCount,
                    onClick = { onSubCategorySelected(subCategory) }
                )
            }
        }
    }
}

@Composable
private fun SubCategoryCard(
    subCategory: SubCategory,
    summary: ModeStatSummary,
    itemCount: Int,
    onClick: () -> Unit
) {
    val isAvailable = itemCount >= 2
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .alpha(if (isAvailable) 1f else 0.62f)
            .then(if (isAvailable) Modifier.clickable(onClick = onClick) else Modifier),
        shape = RoundedCornerShape(22.dp),
        border = BorderStroke(1.dp, GermanyGold.copy(alpha = if (isAvailable) 0.32f else 0.14f)),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        elevation = CardDefaults.cardElevation(defaultElevation = 5.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(subCategory.name, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                    Text(subCategory.description, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                Text("›", color = GermanyGold, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
            }
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                SmallValue("Items", itemCount.toString())
                SmallValue("Highscore", summary.highScore.toString())
                SmallValue("Streak", summary.bestStreak.toString())
            }
            if (!isAvailable) {
                Text(
                    text = "Noch nicht genug Items für einen Endless Run.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.bodySmall
                )
            }
        }
    }
}

@Composable
private fun SmallValue(label: String, value: String) {
    Column {
        Text(value, style = MaterialTheme.typography.titleMedium, color = GermanyGold, fontWeight = FontWeight.ExtraBold)
        Text(label, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
