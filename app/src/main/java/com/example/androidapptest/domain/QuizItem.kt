package com.example.androidapptest.domain

data class QuizItem(
    val id: Int,
    val title: String,
    val metric: String,
    val value: Int,
    val displayValue: String,
    val category: QuizCategory,
    val detail: String
)
