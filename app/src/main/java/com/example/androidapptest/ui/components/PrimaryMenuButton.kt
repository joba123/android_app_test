package com.example.androidapptest.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.androidapptest.ui.theme.GermanyGold

@Composable
fun PrimaryMenuButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    outlined: Boolean = false
) {
    val shape = RoundedCornerShape(22.dp)
    val buttonModifier = modifier
        .fillMaxWidth()
        .height(58.dp)
    if (outlined) {
        OutlinedButton(
            onClick = onClick,
            enabled = enabled,
            shape = shape,
            border = BorderStroke(1.dp, GermanyGold.copy(alpha = 0.42f)),
            modifier = buttonModifier
        ) {
            Text(text = text, fontWeight = FontWeight.ExtraBold)
        }
    } else {
        Button(
            onClick = onClick,
            enabled = enabled,
            shape = shape,
            elevation = ButtonDefaults.buttonElevation(defaultElevation = 8.dp, pressedElevation = 2.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary
            ),
            modifier = buttonModifier
        ) {
            Text(text = text, fontWeight = FontWeight.Black)
        }
    }
}
