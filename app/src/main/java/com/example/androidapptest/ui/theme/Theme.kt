package com.example.androidapptest.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColors = darkColorScheme(
    primary = GermanyGold,
    onPrimary = NightBlack,
    secondary = GermanyRed,
    onSecondary = TextPrimary,
    background = NightBlack,
    onBackground = TextPrimary,
    surface = Graphite,
    onSurface = TextPrimary,
    surfaceVariant = SoftGraphite,
    onSurfaceVariant = TextSecondary,
    error = GermanyRed
)

@Composable
fun DeutschlandQuizTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColors,
        typography = Typography,
        content = content
    )
}
