package com.example.androidapptest.data.local

import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.data.model.SubCategory

object ComparisonCatalog {
    val mainCategories = listOf(
        MainCategory("football", "Fußball", "Vereine, Stadien, Werte und Reichweite", "⚽"),
        MainCategory("germany", "Deutschland", "Städte, Länder, Fläche und Alltag", "🇩🇪"),
        MainCategory("cars", "Autos", "Leistung, Preise und technische Daten", "🚗"),
        MainCategory("daily_life", "Preise & Alltag", "Kosten, Konsum und tägliche Ausgaben", "🛒"),
        MainCategory("companies", "Unternehmen", "Mitarbeitende, Umsatz und Marktwerte", "🏢"),
        MainCategory("social_media", "Social Media", "Follower, Abos und Reichweiten", "📱"),
        MainCategory("gaming", "Gaming", "Verkäufe, Spielerzahlen und Bewertungen", "🎮"),
        MainCategory("geography", "Geografie", "Fläche, Höhe, Einwohner und Distanzen", "🗺️")
    )

    val subCategories = listOf(
        SubCategory("market_value", "football", "Marktwert", "Geschätzte Kaderwerte deutscher Vereine", "football_market_value", "Marktwert"),
        SubCategory("stadium_capacity", "football", "Stadionkapazität", "Wie viele Fans passen ins Stadion?", "football_stadium_capacity", "Kapazität"),
        SubCategory("club_members", "football", "Vereinsmitglieder", "Mitgliederzahlen großer Vereine", "football_club_members", "Mitglieder"),
        SubCategory("instagram_followers", "football", "Instagram-Follower", "Reichweite deutscher Fußballclubs", "football_instagram_followers", "Instagram-Follower"),
        SubCategory("titles", "football", "Titel", "Nationale und internationale Erfolge", "football_titles", "Titel"),
        SubCategory("attendance", "football", "Zuschauerzahlen", "Typische Heimspiel-Zuschauer", "football_attendance", "Zuschauer"),
        SubCategory("population", "germany", "Einwohnerzahlen", "Einwohner deutscher Städte", "germany_population", "Einwohner"),
        SubCategory("area", "germany", "Fläche", "Fläche deutscher Bundesländer", "germany_area", "Fläche"),
        SubCategory("rent", "germany", "Mieten", "Durchschnittliche Angebotsmieten pro Quadratmeter", "germany_rent", "Miete"),
        SubCategory("salary", "germany", "Durchschnittsgehalt", "Bruttojahresgehälter nach Städten", "germany_salary", "Durchschnittsgehalt"),
        SubCategory("tourists", "germany", "Touristen", "Übernachtungen und Besucherzahlen", "germany_tourists", "Touristen"),
        SubCategory("beer_consumption", "germany", "Bierkonsum", "Biermengen und Pro-Kopf-Werte", "germany_beer_consumption", "Bierkonsum"),
        SubCategory("price", "cars", "Preis", "Ungefähre Listenpreise neuer Modelle", "cars_price", "Preis"),
        SubCategory("horsepower", "cars", "PS", "Motorleistung aktueller Modelle", "cars_horsepower", "PS"),
        SubCategory("top_speed", "cars", "Höchstgeschwindigkeit", "Maximale Geschwindigkeit", "cars_top_speed", "Höchstgeschwindigkeit"),
        SubCategory("consumption", "cars", "Verbrauch", "Verbrauchswerte im Alltag", "cars_consumption", "Verbrauch"),
        SubCategory("production", "cars", "Produktionszahlen", "Gebaut oder verkauft pro Jahr", "cars_production", "Produktionszahlen"),
        SubCategory("doner_prices", "daily_life", "Dönerpreise", "Typische Preise in deutschen Städten", "daily_doner_prices", "Dönerpreis"),
        SubCategory("food_prices", "daily_life", "Lebensmittelpreise", "Preise für alltägliche Produkte", "daily_food_prices", "Lebensmittelpreis"),
        SubCategory("electricity_costs", "daily_life", "Stromkosten", "Kosten pro Kilowattstunde", "daily_electricity_costs", "Strompreis"),
        SubCategory("rent_prices", "daily_life", "Mietpreise", "Alltagsvergleich von Mietkosten", "daily_rent_prices", "Mietpreis"),
        SubCategory("fuel_prices", "daily_life", "Spritpreise", "Preise an der Tankstelle", "daily_fuel_prices", "Spritpreis"),
        SubCategory("employees", "companies", "Mitarbeiterzahl", "Weltweite Mitarbeitendenzahlen", "companies_employees", "Mitarbeitende"),
        SubCategory("revenue", "companies", "Umsatz", "Jahresumsätze großer Unternehmen", "companies_revenue", "Umsatz"),
        SubCategory("market_value", "companies", "Marktwert", "Börsenwerte und Unternehmenswerte", "companies_market_value", "Marktwert"),
        SubCategory("founding_year", "companies", "Gründungsjahr", "Wann wurde das Unternehmen gegründet?", "companies_founding_year", "Gründungsjahr"),
        SubCategory("instagram_followers", "social_media", "Instagram-Follower", "Deutsche Accounts mit großer Reichweite", "social_instagram_followers", "Instagram-Follower"),
        SubCategory("tiktok_followers", "social_media", "TikTok-Follower", "Reichweite auf TikTok", "social_tiktok_followers", "TikTok-Follower"),
        SubCategory("youtube_subscribers", "social_media", "YouTube-Abonnenten", "Kanäle und Abos", "social_youtube_subscribers", "YouTube-Abonnenten"),
        SubCategory("twitch_followers", "social_media", "Twitch-Follower", "Streaming-Reichweite", "social_twitch_followers", "Twitch-Follower"),
        SubCategory("sales", "gaming", "Verkaufszahlen", "Verkäufe bekannter Spiele", "gaming_sales", "Verkaufszahlen"),
        SubCategory("players", "gaming", "Spielerzahlen", "Aktive oder registrierte Spieler", "gaming_players", "Spieler"),
        SubCategory("release_year", "gaming", "Release-Jahr", "Wann erschien das Spiel?", "gaming_release_year", "Release-Jahr"),
        SubCategory("rating", "gaming", "Bewertung", "Wertungen und Scores", "gaming_rating", "Bewertung"),
        SubCategory("area", "geography", "Fläche", "Flächen geografischer Orte", "geography_area", "Fläche"),
        SubCategory("population", "geography", "Einwohner", "Einwohner von Regionen und Orten", "geography_population", "Einwohner"),
        SubCategory("height", "geography", "Höhe", "Berge und Bauwerke", "geography_height", "Höhe"),
        SubCategory("distance", "geography", "Entfernung", "Distanzen zwischen Orten", "geography_distance", "Entfernung")
    )

    private val categoriesById = mainCategories.associateBy { it.id }
    private val subCategoriesByKey = subCategories.associateBy { "${it.categoryId}_${it.id}" }

    val items = listOf(
        item(1, "FC Bayern München", "München", "football", "market_value", 929_000_000, "929 Mio. €", "Rekordmeister mit internationalem Top-Kader"),
        item(2, "Bayer 04 Leverkusen", "Leverkusen", "football", "market_value", 590_000_000, "590 Mio. €", "Werkself mit starkem Kaderwert"),
        item(3, "Borussia Dortmund", "Dortmund", "football", "market_value", 465_000_000, "465 Mio. €", "Bekannt für junge Top-Talente"),
        item(4, "RB Leipzig", "Leipzig", "football", "market_value", 430_000_000, "430 Mio. €", "Viele internationale Talente im Kader"),
        item(5, "VfB Stuttgart", "Stuttgart", "football", "market_value", 320_000_000, "320 Mio. €", "Traditionsclub aus Baden-Württemberg"),
        item(6, "Eintracht Frankfurt", "Frankfurt", "football", "market_value", 300_000_000, "300 Mio. €", "Europa-League-Sieger 2022"),
        item(7, "SC Freiburg", "Freiburg", "football", "market_value", 180_000_000, "180 Mio. €", "Stabiler Ausbildungsverein"),
        item(8, "Werder Bremen", "Bremen", "football", "market_value", 110_000_000, "110 Mio. €", "Norddeutscher Traditionsclub"),
        item(9, "1. FC Köln", "Köln", "football", "market_value", 90_000_000, "90 Mio. €", "Verein mit großer Fanbasis"),
        item(10, "FC St. Pauli", "Hamburg", "football", "market_value", 65_000_000, "65 Mio. €", "Kultclub vom Millerntor"),

        item(11, "Signal Iduna Park", "Dortmund", "football", "stadium_capacity", 81_365, "81.365 Plätze", "Größtes Stadion Deutschlands"),
        item(12, "Allianz Arena", "München", "football", "stadium_capacity", 75_024, "75.024 Plätze", "Heimstadion des FC Bayern"),
        item(13, "Olympiastadion Berlin", "Berlin", "football", "stadium_capacity", 74_475, "74.475 Plätze", "Austragungsort großer Endspiele"),
        item(14, "VELTINS-Arena", "Gelsenkirchen", "football", "stadium_capacity", 62_271, "62.271 Plätze", "Arena mit verschließbarem Dach"),
        item(15, "MHPArena", "Stuttgart", "football", "stadium_capacity", 60_449, "60.449 Plätze", "Stadion des VfB Stuttgart"),
        item(16, "Deutsche Bank Park", "Frankfurt", "football", "stadium_capacity", 58_000, "58.000 Plätze", "Heimat von Eintracht Frankfurt"),
        item(17, "Borussia-Park", "Mönchengladbach", "football", "stadium_capacity", 54_042, "54.042 Plätze", "Stadion am Niederrhein"),
        item(18, "RheinEnergieStadion", "Köln", "football", "stadium_capacity", 50_000, "50.000 Plätze", "Stadion mit vier markanten Türmen"),
        item(19, "Red Bull Arena", "Leipzig", "football", "stadium_capacity", 47_069, "47.069 Plätze", "Modernisierte Arena im alten Zentralstadion"),
        item(20, "Weserstadion", "Bremen", "football", "stadium_capacity", 42_100, "42.100 Plätze", "Direkt an der Weser gelegen"),

        item(21, "FC Bayern München", "München", "football", "club_members", 360_000, "360.000 Mitglieder", "Einer der größten Sportvereine der Welt"),
        item(22, "Borussia Dortmund", "Dortmund", "football", "club_members", 218_000, "218.000 Mitglieder", "Große Fanbasis im Ruhrgebiet"),
        item(23, "FC Schalke 04", "Gelsenkirchen", "football", "club_members", 185_000, "185.000 Mitglieder", "Mitgliederstarker Traditionsverein"),
        item(24, "1. FC Köln", "Köln", "football", "club_members", 140_000, "140.000 Mitglieder", "Der Geißbockclub wächst stark"),
        item(25, "Eintracht Frankfurt", "Frankfurt", "football", "club_members", 140_000, "140.000 Mitglieder", "Sehr mitgliederstarker Verein"),
        item(26, "VfB Stuttgart", "Stuttgart", "football", "club_members", 100_000, "100.000 Mitglieder", "Traditionsclub im Südwesten"),
        item(27, "Werder Bremen", "Bremen", "football", "club_members", 48_000, "48.000 Mitglieder", "Grün-weißer Traditionsverein"),
        item(28, "Hamburger SV", "Hamburg", "football", "club_members", 110_000, "110.000 Mitglieder", "Großer Verein aus dem Norden"),
        item(29, "Hertha BSC", "Berlin", "football", "club_members", 53_000, "53.000 Mitglieder", "Hauptstadtclub mit langer Geschichte"),
        item(30, "1. FC Nürnberg", "Nürnberg", "football", "club_members", 34_000, "34.000 Mitglieder", "Der Club aus Franken"),

        item(31, "Berlin", "Hauptstadt", "germany", "population", 3_755_000, "3,76 Mio.", "Deutschlands größte Stadt"),
        item(32, "Hamburg", "Hansestadt", "germany", "population", 1_892_000, "1,89 Mio.", "Stadt an Elbe und Alster"),
        item(33, "München", "Bayern", "germany", "population", 1_512_000, "1,51 Mio.", "Drittgrößte Stadt Deutschlands"),
        item(34, "Köln", "Nordrhein-Westfalen", "germany", "population", 1_084_000, "1,08 Mio.", "Domstadt am Rhein"),
        item(35, "Frankfurt am Main", "Hessen", "germany", "population", 773_000, "773.000", "Finanzzentrum Deutschlands"),
        item(36, "Stuttgart", "Baden-Württemberg", "germany", "population", 633_000, "633.000", "Autostadt im Kessel"),
        item(37, "Düsseldorf", "Nordrhein-Westfalen", "germany", "population", 629_000, "629.000", "Landeshauptstadt am Rhein"),
        item(38, "Leipzig", "Sachsen", "germany", "population", 616_000, "616.000", "Wachsende Messestadt"),
        item(39, "Dortmund", "Nordrhein-Westfalen", "germany", "population", 594_000, "594.000", "Großstadt im Ruhrgebiet"),
        item(40, "Essen", "Nordrhein-Westfalen", "germany", "population", 584_000, "584.000", "Zentrum des Ruhrgebiets"),

        item(41, "Bayern", "Bundesland", "germany", "area", 70_542, "70.542 km²", "Größtes deutsches Bundesland"),
        item(42, "Niedersachsen", "Bundesland", "germany", "area", 47_710, "47.710 km²", "Flächenland im Norden"),
        item(43, "Baden-Württemberg", "Bundesland", "germany", "area", 35_751, "35.751 km²", "Südwesten Deutschlands"),
        item(44, "Nordrhein-Westfalen", "Bundesland", "germany", "area", 34_112, "34.112 km²", "Bevölkerungsreichstes Bundesland"),
        item(45, "Brandenburg", "Bundesland", "germany", "area", 29_654, "29.654 km²", "Umschließt Berlin"),
        item(46, "Mecklenburg-Vorpommern", "Bundesland", "germany", "area", 23_295, "23.295 km²", "Land an der Ostsee"),
        item(47, "Hessen", "Bundesland", "germany", "area", 21_116, "21.116 km²", "Bundesland in der Mitte"),
        item(48, "Sachsen-Anhalt", "Bundesland", "germany", "area", 20_452, "20.452 km²", "Flächenland im Osten"),
        item(49, "Rheinland-Pfalz", "Bundesland", "germany", "area", 19_858, "19.858 km²", "Weinland am Rhein"),
        item(50, "Sachsen", "Bundesland", "germany", "area", 18_450, "18.450 km²", "Freistaat im Osten"),

        item(51, "München", "Mietmarkt", "germany", "rent", 2_250, "22,50 €/m²", "Einer der teuersten Mietmärkte"),
        item(52, "Frankfurt am Main", "Mietmarkt", "germany", "rent", 1_850, "18,50 €/m²", "Hohe Nachfrage im Bankenviertel"),
        item(53, "Berlin", "Mietmarkt", "germany", "rent", 1_750, "17,50 €/m²", "Stark umkämpfter Wohnungsmarkt"),
        item(54, "Hamburg", "Mietmarkt", "germany", "rent", 1_650, "16,50 €/m²", "Teure Lagen an Alster und Elbe"),
        item(55, "Stuttgart", "Mietmarkt", "germany", "rent", 1_620, "16,20 €/m²", "Knapper Wohnraum im Talkessel"),
        item(56, "Düsseldorf", "Mietmarkt", "germany", "rent", 1_480, "14,80 €/m²", "Beliebte Rheinmetropole"),
        item(57, "Köln", "Mietmarkt", "germany", "rent", 1_430, "14,30 €/m²", "Hohe Nachfrage in Uninähe"),
        item(58, "Leipzig", "Mietmarkt", "germany", "rent", 1_050, "10,50 €/m²", "Weiterhin günstiger als viele Metropolen"),
        item(59, "Dortmund", "Mietmarkt", "germany", "rent", 920, "9,20 €/m²", "Ruhrgebiet mit moderateren Preisen"),
        item(60, "Dresden", "Mietmarkt", "germany", "rent", 980, "9,80 €/m²", "Attraktive Stadt an der Elbe"),

        item(61, "VW Golf GTI", "Kompaktsportler", "cars", "price", 44_500, "44.500 €", "Klassiker der Kompaktklasse"),
        item(62, "BMW M3 Touring", "Sportkombi", "cars", "price", 105_300, "105.300 €", "Performance-Kombi aus München"),
        item(63, "Porsche 911 Carrera", "Sportwagen", "cars", "price", 128_700, "128.700 €", "Ikone aus Zuffenhausen"),
        item(64, "Mercedes-Benz G 500", "Geländewagen", "cars", "price", 130_200, "130.200 €", "Luxus-Offroader"),
        item(65, "Audi RS 6 Avant", "Sportkombi", "cars", "price", 132_000, "132.000 €", "Schneller Kombi aus Ingolstadt"),
        item(66, "Opel Astra", "Kompaktwagen", "cars", "price", 27_000, "27.000 €", "Volumenmodell aus Rüsselsheim"),
        item(67, "VW ID.3 Pro", "Elektroauto", "cars", "price", 39_900, "39.900 €", "Elektrischer Kompaktwagen"),
        item(68, "BMW i5 M60", "Elektrolimousine", "cars", "price", 99_500, "99.500 €", "Elektrische Businessklasse"),
        item(69, "Mercedes-AMG A 45 S", "Kompaktsportler", "cars", "price", 73_000, "73.000 €", "Starker Kompakt-AMG"),
        item(70, "Porsche Taycan", "Elektrosportwagen", "cars", "price", 101_500, "101.500 €", "Sportlicher Elektro-Porsche"),

        item(71, "VW Golf GTI", "Kompaktsportler", "cars", "horsepower", 265, "265 PS", "Seit Jahrzehnten ein GTI-Maßstab"),
        item(72, "BMW M3 Touring", "Sportkombi", "cars", "horsepower", 510, "510 PS", "M-Modell mit Kombiheck"),
        item(73, "Porsche 911 Carrera", "Sportwagen", "cars", "horsepower", 394, "394 PS", "Boxermotor im Heck"),
        item(74, "Mercedes-Benz G 500", "Geländewagen", "cars", "horsepower", 449, "449 PS", "Kraftvoller Luxus-Offroader"),
        item(75, "Audi RS 6 Avant performance", "Sportkombi", "cars", "horsepower", 630, "630 PS", "Extrem schneller Alltagskombi"),
        item(76, "Opel Astra GSe", "Plug-in-Hybrid", "cars", "horsepower", 225, "225 PS", "Sportlicher Astra-Hybrid"),
        item(77, "VW ID.3 Pro", "Elektroauto", "cars", "horsepower", 204, "204 PS", "Elektrischer Kompaktwagen"),
        item(78, "BMW i5 M60", "Elektrolimousine", "cars", "horsepower", 601, "601 PS", "Elektrischer Allradantrieb"),
        item(79, "Mercedes-AMG A 45 S", "Kompaktsportler", "cars", "horsepower", 421, "421 PS", "Sehr leistungsstarker Vierzylinder"),
        item(80, "Porsche Taycan Turbo GT", "Elektrosportwagen", "cars", "horsepower", 1_034, "1.034 PS", "Topmodell der Taycan-Reihe"),

        item(81, "Volkswagen Group", "Wolfsburg", "companies", "employees", 684_000, "684.000 Mitarbeitende", "Einer der größten Autobauer der Welt"),
        item(82, "Deutsche Post DHL", "Bonn", "companies", "employees", 594_000, "594.000 Mitarbeitende", "Globaler Logistikkonzern"),
        item(83, "Bosch", "Gerlingen", "companies", "employees", 429_000, "429.000 Mitarbeitende", "Technologie- und Industriekonzern"),
        item(84, "Siemens", "München", "companies", "employees", 320_000, "320.000 Mitarbeitende", "Industrie- und Technologiekonzern"),
        item(85, "Deutsche Telekom", "Bonn", "companies", "employees", 199_000, "199.000 Mitarbeitende", "Telekommunikationskonzern"),
        item(86, "Mercedes-Benz Group", "Stuttgart", "companies", "employees", 166_000, "166.000 Mitarbeitende", "Premium-Automobilhersteller"),
        item(87, "Allianz", "München", "companies", "employees", 157_000, "157.000 Mitarbeitende", "Großer Versicherungskonzern"),
        item(88, "BMW Group", "München", "companies", "employees", 155_000, "155.000 Mitarbeitende", "Automobilkonzern aus Bayern"),
        item(89, "BASF", "Ludwigshafen", "companies", "employees", 112_000, "112.000 Mitarbeitende", "Chemiekonzern"),
        item(90, "SAP", "Walldorf", "companies", "employees", 108_000, "108.000 Mitarbeitende", "Softwarekonzern"),

        item(91, "FC Bayern München", "Fußballclub", "social_media", "instagram_followers", 42_000_000, "42 Mio. Follower", "International sehr sichtbarer Club"),
        item(92, "Mercedes-AMG", "Automarke", "social_media", "instagram_followers", 17_000_000, "17 Mio. Follower", "Performance-Marke mit starker Bildsprache"),
        item(93, "BMW", "Automarke", "social_media", "instagram_followers", 39_000_000, "39 Mio. Follower", "Globale Automobilmarke"),
        item(94, "Porsche", "Automarke", "social_media", "instagram_followers", 31_000_000, "31 Mio. Follower", "Sportwagen aus Stuttgart"),
        item(95, "Borussia Dortmund", "Fußballclub", "social_media", "instagram_followers", 21_000_000, "21 Mio. Follower", "Große internationale Fanbase"),
        item(96, "Pamela Reif", "Creatorin", "social_media", "instagram_followers", 9_200_000, "9,2 Mio. Follower", "Fitness- und Lifestyle-Content"),
        item(97, "Toni Kroos", "Fußballer", "social_media", "instagram_followers", 49_000_000, "49 Mio. Follower", "Weltmeister und Champions-League-Sieger"),
        item(98, "Dirk Nowitzki", "Basketball-Legende", "social_media", "instagram_followers", 2_200_000, "2,2 Mio. Follower", "NBA-Legende aus Würzburg"),
        item(99, "Julian Draxler", "Fußballer", "social_media", "instagram_followers", 5_000_000, "5 Mio. Follower", "Deutscher Nationalspieler"),
        item(100, "DAZN DACH", "Sportplattform", "social_media", "instagram_followers", 1_900_000, "1,9 Mio. Follower", "Sport-Content im deutschsprachigen Raum")
    )

    fun mainCategory(categoryId: String): MainCategory? = categoriesById[categoryId]

    fun subCategory(categoryId: String, subCategoryId: String): SubCategory? =
        subCategoriesByKey["${categoryId}_$subCategoryId"]

    fun subCategoriesFor(categoryId: String): List<SubCategory> =
        subCategories.filter { it.categoryId == categoryId }

    fun itemsForSubCategory(categoryId: String, subCategoryId: String): List<ComparisonItem> =
        items.filter { it.categoryId == categoryId && it.subcategoryId == subCategoryId }

    fun itemCount(categoryId: String, subCategoryId: String): Int =
        itemsForSubCategory(categoryId, subCategoryId).size

    private fun item(
        id: Int,
        title: String,
        subtitle: String,
        categoryId: String,
        subcategoryId: String,
        value: Int,
        displayValue: String,
        funFact: String
    ): ComparisonItem {
        val category = categoriesById.getValue(categoryId)
        val subCategory = subCategoriesByKey.getValue("${categoryId}_$subcategoryId")
        return ComparisonItem(
            id = id,
            title = title,
            subtitle = subtitle,
            categoryId = category.id,
            categoryName = category.name,
            subcategoryId = subCategory.id,
            subcategoryName = subCategory.name,
            metricId = subCategory.metricId,
            metricName = subCategory.metricName,
            value = value,
            displayValue = displayValue,
            funFact = funFact
        )
    }
}
