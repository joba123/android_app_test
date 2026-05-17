package com.example.androidapptest.data.model

data class MainCategory(
    val id: String,
    val name: String,
    val description: String,
    val icon: String,
    val isGeneral: Boolean = false
)

data class SubCategory(
    val id: String,
    val categoryId: String,
    val name: String,
    val description: String,
    val metricId: String,
    val metricName: String
) {
    val modeKey: String = "${categoryId}_$id"
}

data class ComparisonItem(
    val id: Int,
    val title: String,
    val subtitle: String,
    val categoryId: String,
    val categoryName: String,
    val subcategoryId: String,
    val subcategoryName: String,
    val metricId: String,
    val metricName: String,
    val value: Int,
    val displayValue: String,
    val unit: String? = null,
    val funFact: String? = null,
    val imageName: String? = null
)
