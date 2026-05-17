package com.example.androidapptest.domain.game

import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.data.model.SubCategory

data class GameMode(
    val categoryId: String,
    val categoryName: String,
    val subcategoryId: String? = null,
    val subcategoryName: String? = null,
    val metricId: String? = null,
    val metricName: String? = null,
    val isGeneralMode: Boolean = false
) {
    val statsKey: String = if (isGeneralMode) GENERAL_KEY else "${categoryId}_${subcategoryId.orEmpty()}"
    val displayTitle: String = if (isGeneralMode) "Allgemein" else categoryName
    val displaySubtitle: String = if (isGeneralMode) "Gemischter Endless Run" else subcategoryName.orEmpty()

    companion object {
        const val GENERAL_KEY = "general"

        fun general() = GameMode(
            categoryId = GENERAL_KEY,
            categoryName = "Allgemein",
            isGeneralMode = true
        )

        fun from(category: MainCategory, subCategory: SubCategory) = GameMode(
            categoryId = category.id,
            categoryName = category.name,
            subcategoryId = subCategory.id,
            subcategoryName = subCategory.name,
            metricId = subCategory.metricId,
            metricName = subCategory.metricName
        )
    }
}
