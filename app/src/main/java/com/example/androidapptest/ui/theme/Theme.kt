package com.example.androidapptest.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

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
fun DeutschlandQuizTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = NightBlack.toArgb()
            window.navigationBarColor = NightBlack.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
            WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
        }
    }

    MaterialTheme(
        colorScheme = DarkColors,
        typography = Typography,
        content = content
    )
}
