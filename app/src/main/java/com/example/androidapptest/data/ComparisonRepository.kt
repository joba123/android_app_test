package com.example.androidapptest.data

import com.example.androidapptest.data.local.ComparisonCatalog
import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.data.model.SubCategory

class ComparisonRepository {
    val mainCategories: List<MainCategory> = ComparisonCatalog.mainCategories
    val subCategories: List<SubCategory> = ComparisonCatalog.subCategories
    val allItems: List<ComparisonItem> = ComparisonCatalog.items

    fun mainCategory(categoryId: String): MainCategory? = ComparisonCatalog.mainCategory(categoryId)

    fun subCategory(categoryId: String, subCategoryId: String): SubCategory? =
        ComparisonCatalog.subCategory(categoryId, subCategoryId)

    fun subCategoriesFor(categoryId: String): List<SubCategory> =
        ComparisonCatalog.subCategoriesFor(categoryId)

    fun itemsForSubCategory(categoryId: String, subCategoryId: String): List<ComparisonItem> =
        ComparisonCatalog.itemsForSubCategory(categoryId, subCategoryId)

    fun itemCount(categoryId: String, subCategoryId: String): Int =
        ComparisonCatalog.itemCount(categoryId, subCategoryId)

    fun generalMetricGroups(): List<List<ComparisonItem>> =
        allItems.groupBy { it.metricId }.values.filter { it.size >= 2 }
}
