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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.androidapptest.data.model.CatalogImage
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.ui.components.MenuImageCard
import com.example.androidapptest.ui.components.MenuStatPill
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack

@Composable
fun CategorySelectionScreen(
    categories: List<MainCategory>,
    highScoreForCategory: (MainCategory) -> Int,
    itemCountForCategory: (MainCategory) -> Int,
    previewImagesByCategoryId: Map<String, CatalogImage?>,
    onBack: () -> Unit,
    onCategorySelected: (MainCategory) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(NightBlack, GermanyRed.copy(alpha = 0.16f), NightBlack)))
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(start = 20.dp, top = 22.dp, end = 20.dp, bottom = 28.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = onBack) {
                        Text("←", color = Color.White, style = MaterialTheme.typography.titleLarge)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Kategorien",
                            style = MaterialTheme.typography.headlineMedium,
                            color = Color.White,
                            fontWeight = FontWeight.ExtraBold
                        )
                        Text(
                            text = "Jede Kategorie startet mit eigenen Bildern und Highscores.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }

            items(categories, key = { it.id }) { category ->
                CategoryCard(
                    category = category,
                    image = previewImagesByCategoryId[category.id],
                    itemCount = itemCountForCategory(category),
                    highScore = highScoreForCategory(category),
                    onClick = { onCategorySelected(category) }
                )
            }
        }
    }
}

@Composable
private fun CategoryCard(
    category: MainCategory,
    image: CatalogImage?,
    itemCount: Int,
    highScore: Int,
    onClick: () -> Unit
) {
    MenuImageCard(
        image = image,
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .height(184.dp),
        borderColor = GermanyGold.copy(alpha = 0.30f),
        contentPadding = PaddingValues(20.dp)
    ) {
        Text(
            text = category.icon,
            fontSize = 30.sp,
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
