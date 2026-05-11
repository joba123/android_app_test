package com.example.androidapptest.data

import com.example.androidapptest.domain.Category
import com.example.androidapptest.domain.QuizQuestion

class QuestionRepository {
    private val questions = listOf(
        QuizQuestion("Berlin", "Einwohnerzahl", 3_878_000, "3,88 Mio.", Category.CITIES),
        QuizQuestion("Hamburg", "Einwohnerzahl", 1_910_000, "1,91 Mio.", Category.CITIES),
        QuizQuestion("München", "Einwohnerzahl", 1_512_000, "1,51 Mio.", Category.CITIES),
        QuizQuestion("Köln", "Einwohnerzahl", 1_084_000, "1,08 Mio.", Category.CITIES),
        QuizQuestion("Leipzig", "Einwohnerzahl", 628_000, "628 Tsd.", Category.CITIES),
        QuizQuestion("Dortmund", "Einwohnerzahl", 593_000, "593 Tsd.", Category.CITIES),
        QuizQuestion("FC Bayern München", "Deutsche Meistertitel", 33, "33", Category.FOOTBALL),
        QuizQuestion("Borussia Dortmund", "Deutsche Meistertitel", 8, "8", Category.FOOTBALL),
        QuizQuestion("Borussia Mönchengladbach", "Deutsche Meistertitel", 5, "5", Category.FOOTBALL),
        QuizQuestion("Werder Bremen", "Deutsche Meistertitel", 4, "4", Category.FOOTBALL),
        QuizQuestion("Hamburger SV", "Deutsche Meistertitel", 3, "3", Category.FOOTBALL),
        QuizQuestion("VfB Stuttgart", "Deutsche Meistertitel", 5, "5", Category.FOOTBALL),
        QuizQuestion("Volkswagen Golf", "ungefährer Einstiegspreis", 28_000, "28.000 €", Category.CARS),
        QuizQuestion("BMW 3er", "ungefährer Einstiegspreis", 46_000, "46.000 €", Category.CARS),
        QuizQuestion("Mercedes-Benz C-Klasse", "ungefährer Einstiegspreis", 48_000, "48.000 €", Category.CARS),
        QuizQuestion("Opel Corsa", "ungefährer Einstiegspreis", 20_000, "20.000 €", Category.CARS),
        QuizQuestion("Porsche 911", "ungefährer Einstiegspreis", 128_000, "128.000 €", Category.CARS),
        QuizQuestion("Audi A4", "ungefährer Einstiegspreis", 42_000, "42.000 €", Category.CARS),
        QuizQuestion("Döner", "typischer Preis", 7, "7 €", Category.EVERYDAY),
        QuizQuestion("Deutschlandticket", "Monatspreis", 58, "58 €", Category.EVERYDAY),
        QuizQuestion("Kinoticket", "typischer Preis", 13, "13 €", Category.EVERYDAY),
        QuizQuestion("Cappuccino", "typischer Café-Preis", 4, "4 €", Category.EVERYDAY),
        QuizQuestion("Super E10", "grober Literpreis in Cent", 180, "180 ct", Category.EVERYDAY),
        QuizQuestion("Brezel", "typischer Bäckerei-Preis", 2, "2 €", Category.EVERYDAY),
        QuizQuestion("Bayern", "Fläche", 70_542, "70.542 km²", Category.STATES),
        QuizQuestion("Niedersachsen", "Fläche", 47_710, "47.710 km²", Category.STATES),
        QuizQuestion("Baden-Württemberg", "Fläche", 35_748, "35.748 km²", Category.STATES),
        QuizQuestion("Nordrhein-Westfalen", "Fläche", 34_112, "34.112 km²", Category.STATES),
        QuizQuestion("Saarland", "Fläche", 2_571, "2.571 km²", Category.STATES),
        QuizQuestion("Bremen", "Fläche", 419, "419 km²", Category.STATES),
        QuizQuestion("Volkswagen", "Mitarbeitende weltweit", 684_000, "684 Tsd.", Category.COMPANIES),
        QuizQuestion("Deutsche Bahn", "Mitarbeitende weltweit", 338_000, "338 Tsd.", Category.COMPANIES),
        QuizQuestion("Siemens", "Mitarbeitende weltweit", 320_000, "320 Tsd.", Category.COMPANIES),
        QuizQuestion("Bosch", "Mitarbeitende weltweit", 429_000, "429 Tsd.", Category.COMPANIES),
        QuizQuestion("Deutsche Telekom", "Mitarbeitende weltweit", 200_000, "200 Tsd.", Category.COMPANIES),
        QuizQuestion("SAP", "Mitarbeitende weltweit", 108_000, "108 Tsd.", Category.COMPANIES)
    )

    fun getQuestions(category: Category): List<QuizQuestion> =
        if (category == Category.MIXED) questions else questions.filter { it.category == category }
}
