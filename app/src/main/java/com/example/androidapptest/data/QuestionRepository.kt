package com.example.androidapptest.data

import com.example.androidapptest.domain.QuizCategory
import com.example.androidapptest.domain.QuizItem

class QuestionRepository {
    val categories: List<QuizCategory> = QuizCategory.entries

    private val questions = listOf(
        QuizItem(1, "Berlin", "Einwohner", 3_755_000, "3,76 Mio.", QuizCategory.Cities, "Deutschlands Hauptstadt"),
        QuizItem(2, "Hamburg", "Einwohner", 1_892_000, "1,89 Mio.", QuizCategory.Cities, "Hansestadt an der Elbe"),
        QuizItem(3, "München", "Einwohner", 1_512_000, "1,51 Mio.", QuizCategory.Cities, "Landeshauptstadt Bayerns"),
        QuizItem(4, "Köln", "Einwohner", 1_084_000, "1,08 Mio.", QuizCategory.Cities, "Domstadt am Rhein"),
        QuizItem(5, "Frankfurt am Main", "Einwohner", 773_000, "773 Tsd.", QuizCategory.Cities, "Finanzmetropole"),
        QuizItem(6, "Signal Iduna Park", "Stadionplätze", 81_365, "81.365", QuizCategory.Football, "Heimstadion von Borussia Dortmund"),
        QuizItem(7, "Allianz Arena", "Stadionplätze", 75_024, "75.024", QuizCategory.Football, "Heimstadion des FC Bayern"),
        QuizItem(8, "Olympiastadion Berlin", "Stadionplätze", 74_475, "74.475", QuizCategory.Football, "Traditionsstadion in Berlin"),
        QuizItem(9, "Mercedes-Benz Arena", "Stadionplätze", 60_449, "60.449", QuizCategory.Football, "Heimstadion des VfB Stuttgart"),
        QuizItem(10, "VW Golf GTI", "PS", 265, "265 PS", QuizCategory.Cars, "Kompakter Klassiker"),
        QuizItem(11, "BMW M3 Touring", "PS", 510, "510 PS", QuizCategory.Cars, "Sportkombi aus München"),
        QuizItem(12, "Porsche 911 Carrera", "PS", 394, "394 PS", QuizCategory.Cars, "Sportwagen-Ikone"),
        QuizItem(13, "Mercedes-Benz G-Klasse", "PS", 449, "449 PS", QuizCategory.Cars, "Geländewagen-Legende"),
        QuizItem(14, "Currywurst in Berlin", "Preis in Cent", 450, "4,50 €", QuizCategory.DailyLife, "Imbiss-Klassiker"),
        QuizItem(15, "Deutschlandticket", "Preis in Cent", 5800, "58 €", QuizCategory.DailyLife, "Monatsticket im Nahverkehr"),
        QuizItem(16, "Kinoticket", "Preis in Cent", 1250, "12,50 €", QuizCategory.DailyLife, "Durchschnittlicher Abendpreis"),
        QuizItem(17, "Bayern", "Fläche", 70_542, "70.542 km²", QuizCategory.States, "Größtes Bundesland"),
        QuizItem(18, "Niedersachsen", "Fläche", 47_710, "47.710 km²", QuizCategory.States, "Norddeutsches Flächenland"),
        QuizItem(19, "Baden-Württemberg", "Fläche", 35_751, "35.751 km²", QuizCategory.States, "Südwesten Deutschlands"),
        QuizItem(20, "Nordrhein-Westfalen", "Fläche", 34_112, "34.112 km²", QuizCategory.States, "Bevölkerungsreichstes Bundesland"),
        QuizItem(21, "Volkswagen Group", "Mitarbeitende", 684_000, "684 Tsd.", QuizCategory.Companies, "Automobilkonzern aus Wolfsburg"),
        QuizItem(22, "Deutsche Post DHL", "Mitarbeitende", 594_000, "594 Tsd.", QuizCategory.Companies, "Logistikriese"),
        QuizItem(23, "Siemens", "Mitarbeitende", 320_000, "320 Tsd.", QuizCategory.Companies, "Technologiekonzern"),
        QuizItem(24, "SAP", "Mitarbeitende", 108_000, "108 Tsd.", QuizCategory.Companies, "Softwarekonzern aus Walldorf")
    )

    fun getQuestions(category: QuizCategory): List<QuizItem> {
        return if (category == QuizCategory.Mixed) questions else questions.filter { it.category == category }
    }
}
