package com.example.androidapptest.data

import com.example.androidapptest.domain.QuizCategory
import com.example.androidapptest.domain.QuizItem

class QuestionRepository {
    val categories: List<QuizCategory> = QuizCategory.entries.filter { it != QuizCategory.Mixed }

    private val questions: List<QuizItem> = buildList {
        var id = 1
        repeat(25) {
            add(QuizItem(id++, "Stadt ${it + 1}", "Einwohner", 120_000 + it * 95_000, "${120 + it * 95} Tsd.", QuizCategory.Cities, "Deutsche Stadtfakten"))
            add(QuizItem(id++, "Stadion ${it + 1}", "Stadionplätze", 22_000 + it * 2_450, "${22 + it * 2}.000", QuizCategory.Football, "Kapazität in Deutschland"))
            add(QuizItem(id++, "Auto ${it + 1}", "PS", 90 + it * 18, "${90 + it * 18} PS", QuizCategory.Cars, "Leistung verschiedener Modelle"))
            add(QuizItem(id++, "Alltag ${it + 1}", "Preis in Cent", 180 + it * 75, "${(180 + it * 75) / 100.0} €", QuizCategory.DailyLife, "Preisvergleich in Deutschland"))
            add(QuizItem(id++, "Bundesland ${it + 1}", "Fläche", 2_000 + it * 2_900, "${2 + it * 2} Tsd. km²", QuizCategory.States, "Regionale Kennzahl"))
            add(QuizItem(id++, "Unternehmen ${it + 1}", "Mitarbeitende", 2_500 + it * 8_700, "${2 + it * 8} Tsd.", QuizCategory.Companies, "Unternehmensgröße"))
        }
    }

    fun getQuestions(category: QuizCategory): List<QuizItem> {
        return if (category == QuizCategory.Mixed) questions else questions.filter { it.category == category }
    }
}
