package com.example.androidapptest.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.data.model.SubCategory
import com.example.androidapptest.domain.stats.ModeStatSummary
import com.example.androidapptest.ui.components.MenuImageCard
import com.example.androidapptest.ui.components.MenuStatPill
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack

@Composable
fun SubCategoryScreen(
    category: MainCategory,
    subCategories: List<SubCategory>,
    summaryFor: (SubCategory) -> ModeStatSummary,
    itemCountFor: (SubCategory) -> Int,
    sampleItemFor: (SubCategory) -> ComparisonItem?,
    onBack: () -> Unit,
    onSubCategorySelected: (SubCategory) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(NightBlack, GermanyRed.copy(alpha = 0.14f), NightBlack)))
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(start = 20.dp, top = 22.dp, end = 20.dp, bottom = 28.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = onBack) {
                        Text("←", style = MaterialTheme.typography.titleLarge, color = Color.White)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = category.name,
                            style = MaterialTheme.typography.headlineMedium,
                            color = Color.White,
                            fontWeight = FontWeight.ExtraBold
                        )
                        Text(
                            text = "Unterkategorie wählen",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            items(subCategories, key = { it.modeKey }) { subCategory ->
                val summary = summaryFor(subCategory)
                val itemCount = itemCountFor(subCategory)
                SubCategoryCard(
                    subCategory = subCategory,
                    summary = summary,
                    itemCount = itemCount,
                    item = sampleItemFor(subCategory),
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
    item: ComparisonItem?,
    onClick: () -> Unit
) {
    val isAvailable = itemCount >= 2
    MenuImageCard(
        item = item,
        onClick = if (isAvailable) onClick else null,
        modifier = Modifier
            .fillMaxWidth()
            .height(174.dp)
            .alpha(if (isAvailable) 1f else 0.62f),
        borderColor = GermanyGold.copy(alpha = if (isAvailable) 0.30f else 0.12f),
        contentPadding = PaddingValues(20.dp)
    ) {
        Text(
            text = "›",
            color = GermanyGold,
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.align(Alignment.TopEnd)
        )
        Column(
            modifier = Modifier.align(Alignment.BottomStart),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = subCategory.name,
                style = MaterialTheme.typography.headlineSmall,
                color = Color.White,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = subCategory.description,
                style = MaterialTheme.typography.bodyMedium,
                color = Color.White.copy(alpha = 0.84f),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                MenuStatPill(label = "Items", value = itemCount.toString(), modifier = Modifier.weight(1f))
                MenuStatPill(label = "Highscore", value = summary.highScore.toString(), modifier = Modifier.weight(1f))
                MenuStatPill(label = "Streak", value = summary.bestStreak.toString(), modifier = Modifier.weight(1f))
            }
            if (!isAvailable) {
                Text(
                    text = "Noch nicht genug Items für einen Endless Run.",
                    color = Color.White.copy(alpha = 0.72f),
                    style = MaterialTheme.typography.bodySmall,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}
