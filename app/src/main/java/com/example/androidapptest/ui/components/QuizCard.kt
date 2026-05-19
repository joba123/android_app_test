package com.example.androidapptest.ui.components

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shadow
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.ui.theme.GermanyGold
import com.example.androidapptest.ui.theme.GermanyRed
import com.example.androidapptest.ui.theme.SoftGraphite
import com.example.androidapptest.ui.theme.SuccessGreen

@Composable
fun QuizCard(
    item: ComparisonItem,
    revealValue: Boolean,
    modifier: Modifier = Modifier,
    feedbackCorrect: Boolean? = null,
    roleLabel: String? = null
) {
    val accent = when (feedbackCorrect) {
        true -> SuccessGreen
        false -> GermanyRed
        null -> GermanyGold
    }
    val scale by animateFloatAsState(
        targetValue = if (feedbackCorrect != null) 1.025f else 1f,
        animationSpec = tween(durationMillis = 180),
        label = "card feedback scale"
    )
    val rotation by animateFloatAsState(
        targetValue = if (revealValue) 0f else -4f,
        animationSpec = tween(durationMillis = 260),
        label = "card reveal tilt"
    )
    val imageUrl = item.imageUrl.takeIf { item.imageVerified && !it.isNullOrBlank() }
    val readableTextStyle = MaterialTheme.typography.bodyMedium.copy(
        shadow = Shadow(
            color = Color.Black.copy(alpha = 0.75f),
            offset = Offset(0f, 2f),
            blurRadius = 8f
        )
    )

    Card(
        modifier = modifier
            .scale(scale)
            .graphicsLayer {
                rotationY = rotation
                cameraDistance = 12f * density
            },
        shape = RoundedCornerShape(28.dp),
        border = BorderStroke(1.dp, accent.copy(alpha = 0.45f)),
        colors = CardDefaults.cardColors(containerColor = SoftGraphite),
        elevation = CardDefaults.cardElevation(defaultElevation = 10.dp)
    ) {
        Box(
            modifier = Modifier
                .background(
                    Brush.verticalGradient(
                        colors = listOf(accent.copy(alpha = 0.32f), SoftGraphite, Color.Black.copy(alpha = 0.88f))
                    )
                )
                .fillMaxWidth()
                .defaultMinSize(minHeight = 236.dp)
        ) {
            if (imageUrl != null) {
                AsyncImage(
                    model = imageUrl,
                    contentDescription = item.imageAttributionText ?: item.title,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.matchParentSize()
                )
            }
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(Color.Black.copy(alpha = 0.42f))
            )
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(
                                Color.Black.copy(alpha = 0.18f),
                                Color.Black.copy(alpha = 0.38f),
                                Color.Black.copy(alpha = 0.78f)
                            )
                        )
                    )
            )

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                if (roleLabel != null) {
                    Text(
                        text = roleLabel,
                        style = MaterialTheme.typography.labelLarge,
                        color = accent,
                        fontWeight = FontWeight.ExtraBold,
                        textAlign = TextAlign.Center
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                }
                Text(
                    text = item.title,
                    style = MaterialTheme.typography.headlineSmall.copy(
                        shadow = readableTextStyle.shadow
                    ),
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(10.dp))
                Text(
                    text = item.subtitle,
                    style = readableTextStyle,
                    color = Color.White.copy(alpha = 0.88f),
                    textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(24.dp))
                Text(
                    text = item.metricName,
                    style = MaterialTheme.typography.labelLarge.copy(
                        shadow = readableTextStyle.shadow
                    ),
                    color = accent,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(8.dp))
                AnimatedContent(targetState = revealValue, label = "value reveal") { revealed ->
                    Text(
                        text = if (revealed) item.displayValue else "?",
                        fontSize = if (revealed) 34.sp else 54.sp,
                        lineHeight = 58.sp,
                        color = Color.White,
                        fontWeight = FontWeight.ExtraBold,
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.displaySmall.copy(
                            shadow = readableTextStyle.shadow
                        )
                    )
                }
            }
        }
    }
}
