package com.example.androidapptest.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.foundation.Image
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.androidapptest.R
import com.example.androidapptest.data.model.CatalogImage
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
    overallHighScore: Int,
    lastModeLabel: String?,
    highScoreForCategory: (MainCategory) -> Int,
    itemCountForCategory: (MainCategory) -> Int,
    previewImagesByCategoryId: Map<String, CatalogImage?>,
    onPlay: () -> Unit,
    onCategorySelected: (MainCategory) -> Unit,
    onOpenStats: () -> Unit,
    onOpenSettings: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        NightBlack,
                        GermanyRed.copy(alpha = 0.18f),
                        NightBlack
                    )
                )
            )
    ) {
        AnimatedVisibility(visible = true, enter = fadeIn()) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(start = 20.dp, top = 34.dp, end = 20.dp, bottom = 28.dp),
                verticalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                item {
                    HomeHeader()
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

                item {
                    SectionTitle(title = "Kategorien", subtitle = "Wähle deinen nächsten Run")
                }

                item {
                    LazyRow(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                        items(categories, key = { it.id }) { category ->
                            HomeCategoryCard(
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
        }
    }
}

@Composable
private fun HomeHeader() {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Image(
            painter = painterResource(id = R.drawable.higher_lower_logo),
            contentDescription = "Higher Lower Deutschland Logo",
            contentScale = ContentScale.Fit,
            modifier = Modifier
                .width(184.dp)
                .height(158.dp)
        )
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(5.dp)
        ) {
            Text(
                text = "Higher Lower Deutschland",
                style = MaterialTheme.typography.headlineMedium,
                color = Color.White,
                fontWeight = FontWeight.ExtraBold,
                textAlign = TextAlign.Center
            )
            Text(
                text = "Teste dein Wissen über Deutschland",
                style = MaterialTheme.typography.bodyLarge,
                color = Color.White.copy(alpha = 0.88f),
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center
            )
            Text(
                text = "Städte, Fußball, Bevölkerung, Rekorde & mehr",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth(),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun HomeCategoryCard(
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
