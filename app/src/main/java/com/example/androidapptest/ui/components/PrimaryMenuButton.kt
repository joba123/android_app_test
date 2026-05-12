package com.example.androidapptest.ui.components

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

@Composable
fun PrimaryMenuButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    outlined: Boolean = false
) {
    val shape = RoundedCornerShape(18.dp)
    if (outlined) {
        OutlinedButton(
            onClick = onClick,
            enabled = enabled,
            shape = shape,
            modifier = modifier.fillMaxWidth()
        ) {
            Text(text = text, fontWeight = FontWeight.SemiBold)
        }
    } else {
        Button(
            onClick = onClick,
            enabled = enabled,
            shape = shape,
            colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary
            ),
            modifier = modifier.fillMaxWidth()
        ) {
            Text(text = text, fontWeight = FontWeight.Bold)
        }
    }
}
