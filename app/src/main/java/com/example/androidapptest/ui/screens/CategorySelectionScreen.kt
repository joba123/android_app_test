package com.example.androidapptest.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.NightBlack

@Composable
fun CategorySelectionScreen(
    categories: List<MainCategory>,
    highScoreForCategory: (MainCategory) -> Int,
    onBack: () -> Unit,
    onCategorySelected: (MainCategory) -> Unit
) {
    Box(modifier = Modifier.fillMaxSize().background(Brush.verticalGradient(listOf(NightBlack, GermanyRed.copy(alpha = 0.16f), NightBlack)))) {
        LazyColumn(modifier = Modifier.fillMaxSize().padding(horizontal = 20.dp), contentPadding = PaddingValues(top = 20.dp, bottom = 20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = onBack) { Text("←") }
                    Text("Kategorien", style = MaterialTheme.typography.headlineMedium, color = Color.White, fontWeight = FontWeight.ExtraBold)
                }
            }
            items(categories, key = { it.id }) { category ->
                Card(modifier = Modifier.fillMaxWidth().clickable { onCategorySelected(category) }, shape = RoundedCornerShape(22.dp), border = BorderStroke(1.dp, GermanyRed.copy(alpha = 0.22f)), colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                    Row(modifier = Modifier.fillMaxWidth().padding(18.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                        Text(text = category.icon, fontSize = 30.sp)
                        Column(modifier = Modifier.weight(1f)) {
                            Text(category.name, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.ExtraBold)
                            Text(category.description, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text("Highscore", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                            Text(highScoreForCategory(category).toString(), style = MaterialTheme.typography.titleLarge, color = GermanyGold, fontWeight = FontWeight.Black)
                        }
                    }
                }
            }
        }
    }
}
