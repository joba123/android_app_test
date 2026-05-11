package com.example.androidapptest.ui.components

import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.example.androidapptest.ui.theme.GermanyColors

fun Context.dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

fun cardBackground(color: Int = GermanyColors.Surface, strokeColor: Int = GermanyColors.Gold): GradientDrawable =
    GradientDrawable().apply {
        cornerRadius = 32f
        setColor(color)
        setStroke(2, strokeColor)
    }

fun TextView.styleText(size: Float, color: Int = GermanyColors.White, bold: Boolean = false) {
    textSize = size
    setTextColor(color)
    if (bold) typeface = android.graphics.Typeface.DEFAULT_BOLD
}

fun verticalLayout(context: Context, spacingDp: Int = 0): LinearLayout = LinearLayout(context).apply {
    orientation = LinearLayout.VERTICAL
    gravity = Gravity.CENTER_HORIZONTAL
    setPadding(context.dp(22), context.dp(22), context.dp(22), context.dp(22))
    showDividers = if (spacingDp > 0) LinearLayout.SHOW_DIVIDER_MIDDLE else LinearLayout.SHOW_DIVIDER_NONE
    if (spacingDp > 0) dividerDrawable = object : android.graphics.drawable.ColorDrawable(android.graphics.Color.TRANSPARENT) {
        override fun getIntrinsicHeight(): Int = context.dp(spacingDp)
    }
}

fun menuButton(context: Context, label: String, primary: Boolean = true, enabled: Boolean = true, onClick: () -> Unit): Button =
    Button(context).apply {
        text = label
        textSize = 18f
        isAllCaps = false
        isEnabled = enabled
        setTextColor(if (primary) GermanyColors.Black else GermanyColors.White)
        background = cardBackground(if (primary) GermanyColors.Gold else GermanyColors.SurfaceLight, if (primary) GermanyColors.Gold else GermanyColors.Red)
        setOnClickListener { onClick() }
        layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, context.dp(58))
    }

fun spacer(context: Context, heightDp: Int): View = View(context).apply {
    layoutParams = LinearLayout.LayoutParams(1, context.dp(heightDp))
}
