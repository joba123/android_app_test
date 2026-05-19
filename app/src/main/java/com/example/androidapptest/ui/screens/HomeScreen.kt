package com.example.androidapptest.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shadow
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.ui.components.MenuImageCard
import com.example.androidapptest.ui.components.MenuStatPill
import com.example.androidapptest.ui.components.PrimaryMenuButton
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack

@Composable
fun HomeScreen(
    categories: List<MainCategory>,
    featuredItems: List<ComparisonItem>,
    overallHighScore: Int,
    lastModeLabel: String?,
    highScoreForCategory: (MainCategory) -> Int,
    itemCountForCategory: (MainCategory) -> Int,
    sampleItemForCategory: (MainCategory) -> ComparisonItem?,
    onPlay: () -> Unit,
    onCategorySelected: (MainCategory) -> Unit,
    onOpenStats: () -> Unit,
    onOpenSettings: () -> Unit
) {
    val heroItem = remember(featuredItems) { featuredItems.firstOrNull() }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(colors = listOf(NightBlack, GermanyRed.copy(alpha = 0.18f), NightBlack)))
    ) {
        AnimatedVisibility(visible = true, enter = fadeIn()) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(start = 20.dp, top = 42.dp, end = 20.dp, bottom = 28.dp),
                verticalArrangement = Arrangement.spacedBy(22.dp)
            ) {
                item {
                    HomeHeroCard(
                        item = heroItem,
                        overallHighScore = overallHighScore,
                        lastModeLabel = lastModeLabel
                    )
                }

                item {
                    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        PrimaryMenuButton(text = "Jetzt spielen", onClick = onPlay)
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            PrimaryMenuButton(
                                text = "Highscores",
                                onClick = onOpenStats,
                                outlined = true,
                                modifier = Modifier.weight(1f)
                            )
                            PrimaryMenuButton(
                                text = "Einstellungen",
                                onClick = onOpenSettings,
                                outlined = true,
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }
                }

                item {
                    SectionTitle(title = "Kategorien", subtitle = "Wähle deinen nächsten Run")
                }

                item {
                    LazyRow(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                        items(categories, key = { it.id }) { category ->
                            HomeCategoryCard(
                                category = category,
                                item = sampleItemForCategory(category),
                                itemCount = itemCountForCategory(category),
                                highScore = highScoreForCategory(category),
                                onClick = { onCategorySelected(category) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun HomeHeroCard(
    item: ComparisonItem?,
    overallHighScore: Int,
    lastModeLabel: String?
) {
    val shadow = Shadow(
        color = Color.Black.copy(alpha = 0.85f),
        offset = Offset(0f, 3f),
        blurRadius = 12f
    )

    MenuImageCard(
        item = item,
        modifier = Modifier
            .fillMaxWidth()
            .height(312.dp),
        borderColor = GermanyGold.copy(alpha = 0.46f),
        contentPadding = PaddingValues(24.dp)
    ) {
        Column(
            modifier = Modifier.align(Alignment.BottomStart),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Higher Lower",
                style = MaterialTheme.typography.displaySmall.copy(shadow = shadow),
                color = Color.White,
                fontWeight = FontWeight.ExtraBold
            )
            Text(
                text = "Schätze höher oder niedriger und knacke deinen Highscore!",
                style = MaterialTheme.typography.titleMedium.copy(shadow = shadow),
                color = Color.White.copy(alpha = 0.92f),
                fontWeight = FontWeight.SemiBold
            )
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                MenuStatPill(label = "Highscore", value = overallHighScore.toString())
                if (!lastModeLabel.isNullOrBlank()) {
                    MenuStatPill(label = "Zuletzt", value = lastModeLabel, modifier = Modifier.weight(1f))
                }
            }
        }
    }
}

@Composable
private fun HomeCategoryCard(
    category: MainCategory,
    item: ComparisonItem?,
    itemCount: Int,
    highScore: Int,
    onClick: () -> Unit
) {
    MenuImageCard(
        item = item,
        onClick = onClick,
        modifier = Modifier
            .width(260.dp)
            .height(176.dp),
        borderColor = GermanyGold.copy(alpha = 0.30f)
    ) {
        Text(
            text = category.icon,
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.align(Alignment.TopEnd)
        )
        Column(
            modifier = Modifier.align(Alignment.BottomStart),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = category.name,
                style = MaterialTheme.typography.headlineSmall,
                color = Color.White,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = category.description,
                style = MaterialTheme.typography.bodyMedium,
                color = Color.White.copy(alpha = 0.84f),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                MenuStatPill(label = "Items", value = itemCount.toString())
                MenuStatPill(label = "Highscore", value = highScore.toString())
            }
        }
    }
}

@Composable
private fun SectionTitle(title: String, subtitle: String) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = title,
            style = MaterialTheme.typography.headlineSmall,
            color = Color.White,
            fontWeight = FontWeight.ExtraBold
        )
        Text(
            text = subtitle,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
