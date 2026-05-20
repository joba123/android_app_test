package com.example.androidapptest.data.local

import com.example.androidapptest.data.model.CatalogImage
import com.example.androidapptest.data.model.ComparisonItem
import com.example.androidapptest.data.model.MainCategory
import com.example.androidapptest.data.model.SubCategory
import java.net.URLEncoder

object ComparisonCatalog {
    private const val PEXELS_LICENSE_URL = "https://www.pexels.com/license/"
    private const val PIXABAY_LICENSE_URL = "https://pixabay.com/service/license-summary/"

    private data class ImageMetadata(
        val imageUrl: String,
        val imageSource: String,
        val imageAuthor: String?,
        val imageAttributionText: String,
        val imageLicenseUrl: String,
        val imageSearchQuery: String,
        val imageVerified: Boolean = true
    )

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
        SubCategory("titles", "football", "Titel", "Nationale Meisterschaften und Pokale kombiniert", "football_titles", "Titel"),
        SubCategory("attendance", "football", "Zuschauerschnitt", "Typischer Heimspielzuschauerschnitt", "football_attendance", "Zuschauer"),
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

    private val fallbackImagesBySubCategory = mapOf(
        "football_market_value" to pexelsImage(
            photoId = 9946854,
            author = "Rockwell branding agency",
            searchQuery = "generic football stadium no logo",
            description = "generic football stadium"
        ),
        "football_stadium_capacity" to pexelsImage(
            photoId = 9946854,
            author = "Rockwell branding agency",
            searchQuery = "football stadium seating no logo",
            description = "generic football stadium"
        ),
        "football_club_members" to pexelsImage(
            photoId = 19191521,
            author = "Gergely Badacsonyi",
            searchQuery = "football fans cheering supporters Pexels",
            description = "football supporters cheering"
        ),
        "football_instagram_followers" to pexelsImage(
            photoId = 8886104,
            author = "Brian Ramirez",
            searchQuery = "smartphone Instagram profile followers Pexels",
            description = "smartphone showing an Instagram profile"
        ),
        "football_titles" to wikimediaPhoto(
            fileName = "Trophy of Fußball-Bundesliga in Singapore, 2023.jpg",
            author = "Pangalau",
            description = "Bundesliga Meisterschale",
            license = "CC BY-SA 4.0"
        ),
        "football_attendance" to pexelsImage(
            photoId = 31847342,
            author = "Nur Andi Ravsanjani Gusma",
            searchQuery = "stadium crowd attendance football",
            description = "stadium crowd"
        ),
        "germany_population" to pexelsImage(
            photoId = 13146197,
            author = "Jose Vasquez",
            searchQuery = "germany city skyline",
            description = "Frankfurt skyline"
        ),
        "germany_area" to wikimediaPhoto(
            fileName = "Germany location map.svg",
            author = "NordNordWest",
            description = "Germany location map",
            license = "CC BY-SA 3.0"
        ),
        "germany_rent" to pexelsImage(
            photoId = 2408230,
            author = "Mihar kathiriya",
            searchQuery = "apartment buildings residential buildings",
            description = "two apartment buildings"
        ),
        "germany_salary" to pexelsImage(
            photoId = 7352057,
            author = "Lukasz Radziejewski",
            searchQuery = "euro money cash salary",
            description = "close-up of euro money"
        ),
        "germany_tourists" to pexelsImage(
            photoId = 21274213,
            author = "Linda Gschwentner",
            searchQuery = "germany travel tourism skyline",
            description = "Munich skyline"
        ),
        "germany_beer_consumption" to pexelsImage(
            photoId = 1267360,
            author = "ELEVATE",
            searchQuery = "beer glass oktoberfest",
            description = "beer glasses"
        ),
        "cars_price" to pexelsImage(
            photoId = 11827611,
            author = "Ali Kazal",
            searchQuery = "generic car road no logo",
            description = "generic car on road"
        ),
        "cars_horsepower" to pexelsImage(
            photoId = 14782133,
            author = "David Guerrero",
            searchQuery = "generic cars road no logo",
            description = "generic cars on road"
        ),
        "cars_top_speed" to pexelsImage(
            photoId = 19754775,
            author = "Abdulvahap Demir",
            searchQuery = "car tachometer speedometer needle Pexels",
            description = "tachometer needle in a car"
        ),
        "cars_consumption" to pexelsImage(
            photoId = 6075510,
            author = "Erik Mclean",
            searchQuery = "car dashboard fuel gauge Pexels",
            description = "car dashboard fuel gauge"
        ),
        "cars_production" to pexelsImage(
            photoId = 6289026,
            author = "Monstera Production",
            searchQuery = "rising chart graph growth Pexels",
            description = "rising growth chart"
        ),
        "daily_doner_prices" to pexelsImage(
            photoId = 18062062,
            author = "Oben Kural",
            searchQuery = "appetizing doner kebab plate Pexels",
            description = "doner kebab plate"
        ),
        "daily_food_prices" to pexelsImage(
            photoId = 4199043,
            author = "Jack Sparrow",
            searchQuery = "supermarket groceries fresh vegetables Pexels",
            description = "supermarket groceries"
        ),
        "daily_electricity_costs" to pexelsImage(
            photoId = 414837,
            author = "Pixabay",
            searchQuery = "electricity power lines pylon",
            description = "power lines"
        ),
        "daily_rent_prices" to pexelsImage(
            photoId = 1571463,
            author = "Pixabay",
            searchQuery = "apartment building keys rent",
            description = "apartment building"
        ),
        "daily_fuel_prices" to pexelsImage(
            photoId = 14437598,
            author = "Jedidiah-Jordan O.",
            searchQuery = "gas station fuel pump Pexels",
            description = "fuel pump at a gas station"
        ),
        "companies_employees" to pexelsImage(
            photoId = 13038579,
            author = "Boys in Bristol Photography",
            searchQuery = "modern office building no logo",
            description = "modern office building"
        ),
        "companies_revenue" to pexelsImage(
            photoId = 187041,
            author = "Pixabay",
            searchQuery = "finance chart business growth",
            description = "business chart"
        ),
        "companies_market_value" to pexelsImage(
            photoId = 730547,
            author = "Lukas",
            searchQuery = "stock market trading",
            description = "stock market chart"
        ),
        "companies_founding_year" to pexelsImage(
            photoId = 11177238,
            author = "Hatice Baran",
            searchQuery = "old calendar handwritten notes Pexels",
            description = "old paper calendar"
        ),
        "social_instagram_followers" to pexelsImage(
            photoId = 8886104,
            author = "Brian Ramirez",
            searchQuery = "smartphone Instagram profile followers Pexels",
            description = "smartphone showing an Instagram profile"
        ),
        "social_tiktok_followers" to pexelsImage(
            photoId = 4549408,
            author = "cottonbro studio",
            searchQuery = "tiktok smartphone dance content",
            description = "smartphone content creation"
        ),
        "social_youtube_subscribers" to pexelsImage(
            photoId = 3227986,
            author = "Szabó Viktor",
            searchQuery = "smartphone YouTube app subscribers Pexels",
            description = "smartphone showing YouTube app"
        ),
        "social_twitch_followers" to pexelsImage(
            photoId = 7915437,
            author = "Anthony Shkraba",
            searchQuery = "twitch streamer gaming setup",
            description = "gaming streamer setup"
        ),
        "gaming_sales" to pexelsImage(
            photoId = 5795423,
            author = "Erik Mclean",
            searchQuery = "video games collectibles store shelves Pexels",
            description = "pop culture collectibles and game store shelves"
        ),
        "gaming_players" to pexelsImage(
            photoId = 7915243,
            author = "RDNE Stock project",
            searchQuery = "multiplayer gaming computers esports Pexels",
            description = "people playing computer games"
        ),
        "gaming_release_year" to pexelsImage(
            photoId = 4502978,
            author = "Mateusz Dach",
            searchQuery = "retro video game console cartridge Pexels",
            description = "retro console with cartridge and controller"
        ),
        "gaming_rating" to wikimediaPhoto(
            fileName = "FiveStars2.svg",
            author = "McSush",
            description = "five golden rating stars",
            license = "CC0"
        ),
        "geography_area" to pexelsImage(
            photoId = 269633,
            author = "Pixabay",
            searchQuery = "world map continents",
            description = "world map"
        ),
        "geography_population" to pexelsImage(
            photoId = 13146197,
            author = "Jose Vasquez",
            searchQuery = "city skyline population Pexels",
            description = "city skyline"
        ),
        "geography_height" to pexelsImage(
            photoId = 417173,
            author = "Stephan Seeber",
            searchQuery = "mountain peak summit snow",
            description = "mountain summit"
        ),
        "geography_distance" to pexelsImage(
            photoId = 27103750,
            author = "Alexis Leandro Jeria Bocca",
            searchQuery = "road sign in the distance Pexels",
            description = "road leading into the distance"
        )
    )

    private val imagesByTitle = mapOf(
        // === Cars (existing curated set) ===
        "VW Golf GTI" to pexelsImage(28447308, "Ertuğrul Tohma", "VW Golf GTI red forest road Pexels", "Volkswagen Golf GTI on a forest road"),
        "BMW M3 Touring" to pixabayImage("https://cdn.pixabay.com/photo/2017/11/22/16/44/bmw-m3-2970899_1280.jpg", "Toby_Parsons", "BMW M3 Pixabay", "BMW M3 car"),
        "Porsche 911 Carrera" to pixabayImage("https://cdn.pixabay.com/photo/2020/12/01/18/06/porsche-911-gt2-5795128_1280.jpg", "Ultra_Media", "Porsche 911 Carrera sports car Pixabay", "Porsche 911 sports car"),
        "Mercedes-Benz G 500" to pexelsImage(17350681, "Mike Bird", "Mercedes G Class Pexels", "Mercedes G-Class SUV"),
        "Audi RS 6 Avant" to pexelsImage(1054211, "Mike Bird", "Audi RS 6 Avant Pexels", "blue Audi RS 6 wagon"),
        "Audi RS 6 Avant performance" to pexelsImage(1054211, "Mike Bird", "Audi RS 6 Avant performance Pexels", "blue Audi RS 6 wagon"),
        "Opel Astra" to pixabayImage("https://cdn.pixabay.com/photo/2018/09/26/20/28/opel-3705545_1280.jpg", "Arcaion", "Opel Astra red hatchback Pixabay", "red Opel Astra"),
        "Opel Astra GSe" to pixabayImage("https://cdn.pixabay.com/photo/2018/09/26/20/28/opel-3705545_1280.jpg", "Arcaion", "Opel Astra GSe red hatchback Pixabay", "red Opel Astra"),
        "VW ID.3 Pro" to pexelsImage(14209241, "txomcs", "Volkswagen ID.3 Pexels", "Volkswagen ID.3 electric car"),
        "BMW i5 M60" to pexelsImage(20200900, "Esmihel Muhammed", "BMW i5 Pexels", "blue BMW i5"),
        "Mercedes-AMG A 45 S" to pixabayImage("https://cdn.pixabay.com/photo/2021/11/26/17/35/mercedes-amg-a45-6826323_1280.jpg", "MelikHamdi", "Mercedes AMG A45 Pixabay", "Mercedes-AMG A45"),
        "Porsche Taycan" to pixabayImage("https://cdn.pixabay.com/photo/2022/12/01/21/34/porsche-taycan-7629824_1280.jpg", "alandsmann", "Porsche Taycan Pixabay", "Porsche Taycan model"),
        "Porsche Taycan Turbo GT" to pixabayImage("https://cdn.pixabay.com/photo/2022/12/01/21/34/porsche-taycan-7629824_1280.jpg", "alandsmann", "Porsche Taycan Turbo GT Pixabay", "Porsche Taycan model"),
        // === Cities (existing curated set) ===
        "Berlin" to pexelsImage(1057842, "anna-m. w.", "Berlin skyline Pexels", "Berlin skyline"),
        "Hamburg" to pexelsImage(30095370, "Niklas Jeromin", "Hamburg Elbphilharmonie Pexels", "Elbphilharmonie facade in Hamburg"),
        "München" to pexelsImage(21274213, "Linda Gschwentner", "Munich skyline Pexels", "Munich skyline"),
        "Köln" to pexelsImage(35384329, "Oğuzhan Aşcıoğlu", "Cologne Cathedral Hohenzollern Bridge Pexels", "Cologne Cathedral and Hohenzollern Bridge"),
        "Frankfurt am Main" to pexelsImage(13146197, "Jose Vasquez", "Frankfurt skyline Pexels", "Frankfurt skyline"),
        "Kölner Dom" to wikimediaPhoto("Kölner Dom.jpg", "Tobi 87", "Cologne Cathedral", "CC BY 3.0 / GFDL"),
        "Brocken" to wikimediaPhoto("0 2010 3224 Gipfelregion Brocken im Harz.jpg", "W. Bulach", "Brocken summit region", "CC BY-SA 4.0")
    )

    private val geographyPopulationImagesByTitle = mapOf(
        "Hamburg" to localImage("geo_population_hamburg", "Hamburg city view from local Städte folder"),
        "Köln" to localImage("geo_population_koeln", "Cologne city view from local Städte folder"),
        "Frankfurt am Main" to localImage("geo_population_frankfurt", "Frankfurt city view from local Städte folder"),
        "Stuttgart" to localImage("geo_population_stuttgart", "Stuttgart city view from local Städte folder"),
        "Düsseldorf" to localImage("geo_population_duesseldorf", "Düsseldorf city view from local Städte folder"),
        "Dortmund" to localImage("geo_population_dortmund", "Dortmund city view from local Städte folder")
    )

    private val footballStadiumImagesByTitle = mapOf(
        "Signal Iduna Park" to localImage("football_borussia_dortmund", "Dortmund stadium crowd"),
        "Allianz Arena" to localImage("football_allianz_arena", "Allianz Arena exterior"),
        "Olympiastadion Berlin" to localImage("football_hertha_bsc", "Olympiastadion Berlin interior"),
        "VELTINS-Arena" to wikimediaPhoto("Veltins-Arena Panorama.jpg", null, "Veltins-Arena panorama", "Wikimedia Commons license"),
        "MHPArena" to localImage("football_vfb_stuttgart", "Stuttgart football context"),
        "Deutsche Bank Park" to localImage("football_frankfurt", "Frankfurt skyline"),
        "Volksparkstadion" to localImage("football_hamburg", "Hamburg city and football context"),
        "Merkur Spiel-Arena" to wikimediaPhoto("Merkur-Spiel-Arena.jpg", null, "Merkur Spiel-Arena", "Wikimedia Commons license"),
        "Borussia-Park" to localImage("football_moenchengladbach", "Mönchengladbach football context"),
        "RheinEnergieStadion" to localImage("football_koeln", "Cologne stadium view"),
        "Red Bull Arena" to localImage("football_rb_leipzig", "Leipzig football context"),
        "Weserstadion" to localImage("football_werder_bremen", "Bremen football context"),
        "BayArena" to localImage("football_bayer_leverkusen", "Bayer tower in Leverkusen"),
        "Europa-Park Stadion" to localImage("football_sc_freiburg", "Freiburg football context"),
        "MEWA ARENA" to localImage("football_fsv_mainz_05", "Mainz football context"),
        "MEWA ARENA Mainz" to localImage("football_fsv_mainz_05", "Mainz football context"),
        "Volkswagen Arena" to localImage("football_vfl_wolfsburg", "Volkswagen Arena exterior"),
        "WWK Arena" to localImage("football_fc_augsburg", "Augsburg football context"),
        "Stadion An der Alten Försterei" to wikimediaPhoto("19-08-17-Stadion-an-der-alten-Foersterei-DJI 0272.jpg", "Ralf Roletschek", "Stadion An der Alten Försterei", "CC BY-SA"),
        "Millerntor-Stadion" to localImage("football_st_pauli", "Millerntor and St. Pauli context"),
        "Voith-Arena" to localImage("football_heidenheim", "Heidenheim football context"),
        "PreZero Arena" to localImage("football_tsg_hoffenheim", "Hoffenheim football context"),
        "HDI-Arena" to wikimediaPhoto("2013-08-28 HDI-Arena Hannover.jpg", "Tim Rademacher", "HDI-Arena Hannover", "CC BY-SA 4.0"),
        "Max-Morlock-Stadion" to wikimediaPhoto("Das Max-Morlock-Stadion im Sommer 2025.jpg", null, "Max-Morlock-Stadion Nürnberg", "CC BY 4.0"),
        "Wildparkstadion" to wikimediaPhoto("Wildparkstadion.jpg", "Sven Scharr", "Wildparkstadion Karlsruhe", "CC BY 3.0"),
        "Eintracht-Stadion" to wikimediaPhoto("EintrachtStadionAußen.jpg", "Kassandro", "Eintracht-Stadion Braunschweig", "Wikimedia Commons license"),
        "Fritz-Walter-Stadion" to wikimediaPhoto("FIFA-Fritz-Walter-Stadion07.JPG", null, "Fritz-Walter-Stadion Kaiserslautern", "Wikimedia Commons license"),
        "Holstein-Stadion" to wikimediaPhoto("Holsteinstadion-Kiel.jpg", null, "Holstein-Stadion Kiel", "Wikimedia Commons license"),
        "Merck-Stadion am Böllenfalltor" to wikimediaPhoto("Merck-Stadion am Böllenfalltor.jpg", "Twine333", "Merck-Stadion am Böllenfalltor", "CC BY-SA 4.0"),
        "Home Deluxe Arena" to wikimediaPhoto("Benteler Arena innen.jpg", null, "Home Deluxe Arena Paderborn", "Wikimedia Commons license"),
        "Avnet Arena" to wikimediaPhoto("MDCC-Arena.jpg", null, "Avnet Arena Magdeburg", "Wikimedia Commons license"),
        "Waldstadion Kaiserlinde" to localImage("football_elversberg", "SV Elversberg match scene"),
        "SchücoArena" to localImage("football_bielefeld", "Bielefeld city sign"),
        "Sportpark Ronhof" to localImage("football_spvgg_fuerth", "Fürth football context"),
        "Donaustadion" to localImage("football_ssv_ulm", "Ulm football context")
    )

    private val footballClubImagesByTitle = mapOf(
        "FC Bayern München" to footballStadiumImagesByTitle.getValue("Allianz Arena"),
        "Bayer 04 Leverkusen" to localImage("football_bayer_leverkusen", "Bayer tower in Leverkusen"),
        "Borussia Dortmund" to footballStadiumImagesByTitle.getValue("Signal Iduna Park"),
        "RB Leipzig" to footballStadiumImagesByTitle.getValue("Red Bull Arena"),
        "VfB Stuttgart" to footballStadiumImagesByTitle.getValue("MHPArena"),
        "Eintracht Frankfurt" to footballStadiumImagesByTitle.getValue("Deutsche Bank Park"),
        "TSG 1899 Hoffenheim" to footballStadiumImagesByTitle.getValue("PreZero Arena"),
        "VfL Wolfsburg" to localImage("football_vfl_wolfsburg", "Wolfsburg stadium context"),
        "SC Freiburg" to footballStadiumImagesByTitle.getValue("Europa-Park Stadion"),
        "Borussia Mönchengladbach" to footballStadiumImagesByTitle.getValue("Borussia-Park"),
        "1. FSV Mainz 05" to footballStadiumImagesByTitle.getValue("MEWA ARENA"),
        "Werder Bremen" to footballStadiumImagesByTitle.getValue("Weserstadion"),
        "1. FC Union Berlin" to footballStadiumImagesByTitle.getValue("Stadion An der Alten Försterei"),
        "FC Augsburg" to footballStadiumImagesByTitle.getValue("WWK Arena"),
        "1. FC Köln" to footballStadiumImagesByTitle.getValue("RheinEnergieStadion"),
        "VfL Bochum" to localImage("football_bochum", "Bochum city sign"),
        "FC St. Pauli" to footballStadiumImagesByTitle.getValue("Millerntor-Stadion"),
        "Hamburger SV" to localImage("football_hamburg", "Hamburg city context"),
        "Hertha BSC" to footballStadiumImagesByTitle.getValue("Olympiastadion Berlin"),
        "Hannover 96" to footballStadiumImagesByTitle.getValue("HDI-Arena"),
        "FC Schalke 04" to footballStadiumImagesByTitle.getValue("VELTINS-Arena"),
        "1. FC Nürnberg" to footballStadiumImagesByTitle.getValue("Max-Morlock-Stadion"),
        "Fortuna Düsseldorf" to footballStadiumImagesByTitle.getValue("Merkur Spiel-Arena"),
        "Karlsruher SC" to footballStadiumImagesByTitle.getValue("Wildparkstadion"),
        "Eintracht Braunschweig" to footballStadiumImagesByTitle.getValue("Eintracht-Stadion"),
        "1. FC Kaiserslautern" to footballStadiumImagesByTitle.getValue("Fritz-Walter-Stadion"),
        "DFB-Team" to localImage("football_deutschland_flagge", "Germany flag"),
        "1. FC Heidenheim" to footballStadiumImagesByTitle.getValue("Voith-Arena"),
        "Holstein Kiel" to footballStadiumImagesByTitle.getValue("Holstein-Stadion"),
        "SV Darmstadt 98" to footballStadiumImagesByTitle.getValue("Merck-Stadion am Böllenfalltor"),
        "SC Paderborn 07" to footballStadiumImagesByTitle.getValue("Home Deluxe Arena"),
        "1. FC Magdeburg" to footballStadiumImagesByTitle.getValue("Avnet Arena"),
        "SV Elversberg" to footballStadiumImagesByTitle.getValue("Waldstadion Kaiserlinde"),
        "Arminia Bielefeld" to footballStadiumImagesByTitle.getValue("SchücoArena"),
        "SpVgg Greuther Fürth" to footballStadiumImagesByTitle.getValue("Sportpark Ronhof"),
        "SSV Ulm 1846" to footballStadiumImagesByTitle.getValue("Donaustadion")
    )

    private val footballAttendanceImagesByTitle = mapOf(
        "Borussia Dortmund" to footballStadiumImagesByTitle.getValue("Signal Iduna Park"),
        "FC Bayern München" to footballStadiumImagesByTitle.getValue("Allianz Arena"),
        "FC Schalke 04" to footballStadiumImagesByTitle.getValue("VELTINS-Arena"),
        "VfB Stuttgart" to footballStadiumImagesByTitle.getValue("MHPArena"),
        "Eintracht Frankfurt" to footballStadiumImagesByTitle.getValue("Deutsche Bank Park"),
        "Hamburger SV" to footballStadiumImagesByTitle.getValue("Volksparkstadion"),
        "Borussia Mönchengladbach" to footballStadiumImagesByTitle.getValue("Borussia-Park"),
        "Hertha BSC" to footballStadiumImagesByTitle.getValue("Olympiastadion Berlin"),
        "1. FC Köln" to footballStadiumImagesByTitle.getValue("RheinEnergieStadion"),
        "RB Leipzig" to footballStadiumImagesByTitle.getValue("Red Bull Arena"),
        "Werder Bremen" to footballStadiumImagesByTitle.getValue("Weserstadion"),
        "SC Freiburg" to footballStadiumImagesByTitle.getValue("Europa-Park Stadion"),
        "MEWA ARENA Mainz" to footballStadiumImagesByTitle.getValue("MEWA ARENA"),
        "Bayer 04 Leverkusen" to footballStadiumImagesByTitle.getValue("BayArena"),
        "1. FC Union Berlin" to footballStadiumImagesByTitle.getValue("Stadion An der Alten Försterei"),
        "VfL Wolfsburg" to footballStadiumImagesByTitle.getValue("Volkswagen Arena"),
        "FC Augsburg" to footballStadiumImagesByTitle.getValue("WWK Arena"),
        "FC St. Pauli" to footballStadiumImagesByTitle.getValue("Millerntor-Stadion"),
        "1. FC Heidenheim" to footballStadiumImagesByTitle.getValue("Voith-Arena"),
        "Holstein Kiel" to footballStadiumImagesByTitle.getValue("Holstein-Stadion"),
        "SV Darmstadt 98" to footballStadiumImagesByTitle.getValue("Merck-Stadion am Böllenfalltor"),
        "SC Paderborn 07" to footballStadiumImagesByTitle.getValue("Home Deluxe Arena"),
        "1. FC Magdeburg" to footballStadiumImagesByTitle.getValue("Avnet Arena"),
        "SV Elversberg" to footballStadiumImagesByTitle.getValue("Waldstadion Kaiserlinde"),
        "Arminia Bielefeld" to footballStadiumImagesByTitle.getValue("SchücoArena"),
        "SpVgg Greuther Fürth" to footballStadiumImagesByTitle.getValue("Sportpark Ronhof"),
        "SSV Ulm 1846" to footballStadiumImagesByTitle.getValue("Donaustadion")
    )

    val items: List<ComparisonItem> = buildItems()

    private fun buildItems(): List<ComparisonItem> {
        val list = mutableListOf<ComparisonItem>()
        var nextId = 0
        fun add(
            title: String,
            subtitle: String,
            categoryId: String,
            subcategoryId: String,
            value: Int,
            displayValue: String,
            funFact: String
        ) {
            nextId += 1
            list += buildItem(nextId, title, subtitle, categoryId, subcategoryId, value, displayValue, funFact)
        }

        // ============================================================
        // FOOTBALL — Marktwert (geschätzter Kaderwert in €, Quelle: Transfermarkt-Bereich)
        // ============================================================
        add("FC Bayern München", "München", "football", "market_value", 929_000_000, "929 Mio. €", "Rekordmeister mit internationalem Top-Kader")
        add("Bayer 04 Leverkusen", "Leverkusen", "football", "market_value", 590_000_000, "590 Mio. €", "Werkself mit starkem Kaderwert")
        add("Borussia Dortmund", "Dortmund", "football", "market_value", 465_000_000, "465 Mio. €", "Bekannt für junge Top-Talente")
        add("RB Leipzig", "Leipzig", "football", "market_value", 430_000_000, "430 Mio. €", "Viele internationale Talente im Kader")
        add("VfB Stuttgart", "Stuttgart", "football", "market_value", 320_000_000, "320 Mio. €", "Traditionsclub aus Baden-Württemberg")
        add("Eintracht Frankfurt", "Frankfurt", "football", "market_value", 300_000_000, "300 Mio. €", "Europa-League-Sieger 2022")
        add("TSG 1899 Hoffenheim", "Sinsheim", "football", "market_value", 175_000_000, "175 Mio. €", "Dorfclub mit Bundesliga-Etat")
        add("VfL Wolfsburg", "Wolfsburg", "football", "market_value", 165_000_000, "165 Mio. €", "Werksclub des VW-Konzerns")
        add("SC Freiburg", "Freiburg", "football", "market_value", 180_000_000, "180 Mio. €", "Stabiler Ausbildungsverein")
        add("Borussia Mönchengladbach", "Mönchengladbach", "football", "market_value", 150_000_000, "150 Mio. €", "Fohlen-Elf vom Niederrhein")
        add("1. FSV Mainz 05", "Mainz", "football", "market_value", 120_000_000, "120 Mio. €", "Karnevalsclub mit Bundesligaausdauer")
        add("Werder Bremen", "Bremen", "football", "market_value", 110_000_000, "110 Mio. €", "Norddeutscher Traditionsclub")
        add("1. FC Union Berlin", "Berlin", "football", "market_value", 105_000_000, "105 Mio. €", "Köpenicker mit eigenem Stadionbau")
        add("FC Augsburg", "Augsburg", "football", "market_value", 95_000_000, "95 Mio. €", "Schwäbischer Bundesligist")
        add("1. FC Köln", "Köln", "football", "market_value", 90_000_000, "90 Mio. €", "Verein mit großer Fanbasis")
        add("VfL Bochum", "Bochum", "football", "market_value", 70_000_000, "70 Mio. €", "Tradition aus dem Ruhrpott")
        add("FC St. Pauli", "Hamburg", "football", "market_value", 65_000_000, "65 Mio. €", "Kultclub vom Millerntor")
        add("Hamburger SV", "Hamburg", "football", "market_value", 75_000_000, "75 Mio. €", "Bundesliga-Dino in der 2. Liga")
        add("Hertha BSC", "Berlin", "football", "market_value", 60_000_000, "60 Mio. €", "Hauptstadtclub aus Charlottenburg")
        add("Hannover 96", "Hannover", "football", "market_value", 45_000_000, "45 Mio. €", "Roter Traditionsclub aus Niedersachsen")
        add("Holstein Kiel", "Kiel", "football", "market_value", 41_000_000, "41 Mio. €", "Nordclub mit jüngerer Bundesliga-Erfahrung")
        add("SV Darmstadt 98", "Darmstadt", "football", "market_value", 31_000_000, "31 Mio. €", "Traditionsclub vom Böllenfalltor")
        add("SC Paderborn 07", "Paderborn", "football", "market_value", 30_000_000, "30 Mio. €", "OWL-Club mit schnellem Umschaltspiel")
        add("1. FC Magdeburg", "Magdeburg", "football", "market_value", 25_000_000, "25 Mio. €", "Ostclub mit großer Heimkulisse")
        add("SV Elversberg", "Spiesen-Elversberg", "football", "market_value", 21_000_000, "21 Mio. €", "Kleiner Standort mit starkem Zweitliga-Auftritt")
        add("Arminia Bielefeld", "Bielefeld", "football", "market_value", 19_000_000, "19 Mio. €", "Traditionsclub aus Ostwestfalen")
        add("SpVgg Greuther Fürth", "Fürth", "football", "market_value", 27_000_000, "27 Mio. €", "Fränkischer Traditionsverein")
        add("SSV Ulm 1846", "Ulm", "football", "market_value", 8_000_000, "8 Mio. €", "Aufsteiger mit markanter Stadtidentität")

        // ============================================================
        // FOOTBALL — Stadionkapazität (Plätze)
        // ============================================================
        add("Signal Iduna Park", "Dortmund", "football", "stadium_capacity", 81_365, "81.365 Plätze", "Größtes Stadion Deutschlands")
        add("Allianz Arena", "München", "football", "stadium_capacity", 75_024, "75.024 Plätze", "Heimstadion des FC Bayern")
        add("Olympiastadion Berlin", "Berlin", "football", "stadium_capacity", 74_475, "74.475 Plätze", "Austragungsort großer Endspiele")
        add("VELTINS-Arena", "Gelsenkirchen", "football", "stadium_capacity", 62_271, "62.271 Plätze", "Arena mit verschließbarem Dach")
        add("MHPArena", "Stuttgart", "football", "stadium_capacity", 60_449, "60.449 Plätze", "Stadion des VfB Stuttgart")
        add("Deutsche Bank Park", "Frankfurt", "football", "stadium_capacity", 58_000, "58.000 Plätze", "Heimat von Eintracht Frankfurt")
        add("Volksparkstadion", "Hamburg", "football", "stadium_capacity", 57_000, "57.000 Plätze", "HSV-Heimstadion im Westen Hamburgs")
        add("Merkur Spiel-Arena", "Düsseldorf", "football", "stadium_capacity", 54_600, "54.600 Plätze", "Multifunktionsarena am Rhein")
        add("Borussia-Park", "Mönchengladbach", "football", "stadium_capacity", 54_042, "54.042 Plätze", "Stadion am Niederrhein")
        add("RheinEnergieStadion", "Köln", "football", "stadium_capacity", 50_000, "50.000 Plätze", "Stadion mit vier markanten Türmen")
        add("Red Bull Arena", "Leipzig", "football", "stadium_capacity", 47_069, "47.069 Plätze", "Modernisierte Arena im alten Zentralstadion")
        add("Weserstadion", "Bremen", "football", "stadium_capacity", 42_100, "42.100 Plätze", "Direkt an der Weser gelegen")
        add("BayArena", "Leverkusen", "football", "stadium_capacity", 30_210, "30.210 Plätze", "Heimstadion von Bayer 04")
        add("Europa-Park Stadion", "Freiburg", "football", "stadium_capacity", 34_700, "34.700 Plätze", "Neubau des SC Freiburg")
        add("MEWA ARENA", "Mainz", "football", "stadium_capacity", 33_305, "33.305 Plätze", "Stadion des 1. FSV Mainz 05")
        add("Volkswagen Arena", "Wolfsburg", "football", "stadium_capacity", 30_000, "30.000 Plätze", "Heimstadion des VfL Wolfsburg")
        add("WWK Arena", "Augsburg", "football", "stadium_capacity", 30_660, "30.660 Plätze", "Stadion in Augsburg-Lechhausen")
        add("Stadion An der Alten Försterei", "Berlin", "football", "stadium_capacity", 22_012, "22.012 Plätze", "Heimat des 1. FC Union Berlin")
        add("Millerntor-Stadion", "Hamburg", "football", "stadium_capacity", 29_546, "29.546 Plätze", "Kultstätte des FC St. Pauli")
        add("Voith-Arena", "Heidenheim", "football", "stadium_capacity", 15_000, "15.000 Plätze", "Kleines Stadion mit Bundesliga-Charme")
        add("Holstein-Stadion", "Kiel", "football", "stadium_capacity", 15_034, "15.034 Plätze", "Kompaktes Stadion im Kieler Norden")
        add("Merck-Stadion am Böllenfalltor", "Darmstadt", "football", "stadium_capacity", 17_650, "17.650 Plätze", "Traditionsspielstätte im Stadtwald")
        add("Home Deluxe Arena", "Paderborn", "football", "stadium_capacity", 15_000, "15.000 Plätze", "Kompakte Arena in Ostwestfalen")
        add("Avnet Arena", "Magdeburg", "football", "stadium_capacity", 30_098, "30.098 Plätze", "Große Bühne des 1. FC Magdeburg")
        add("Waldstadion Kaiserlinde", "Spiesen-Elversberg", "football", "stadium_capacity", 10_000, "10.000 Plätze", "Kleine, enge Zweitliga-Spielstätte")
        add("SchücoArena", "Bielefeld", "football", "stadium_capacity", 26_515, "26.515 Plätze", "Traditionsstadion auf der Alm")
        add("Sportpark Ronhof", "Fürth", "football", "stadium_capacity", 16_626, "16.626 Plätze", "Heimspielstätte der Kleeblätter")
        add("Donaustadion", "Ulm", "football", "stadium_capacity", 19_500, "19.500 Plätze", "Leichtathletik- und Fußballstadion an der Donau")

        // ============================================================
        // FOOTBALL — Vereinsmitglieder
        // ============================================================
        add("FC Bayern München", "München", "football", "club_members", 360_000, "360.000 Mitglieder", "Einer der größten Sportvereine der Welt")
        add("Borussia Dortmund", "Dortmund", "football", "club_members", 218_000, "218.000 Mitglieder", "Große Fanbasis im Ruhrgebiet")
        add("FC Schalke 04", "Gelsenkirchen", "football", "club_members", 185_000, "185.000 Mitglieder", "Mitgliederstarker Traditionsverein")
        add("1. FC Köln", "Köln", "football", "club_members", 140_000, "140.000 Mitglieder", "Der Geißbockclub wächst stark")
        add("Eintracht Frankfurt", "Frankfurt", "football", "club_members", 140_000, "140.000 Mitglieder", "Sehr mitgliederstarker Verein")
        add("Hamburger SV", "Hamburg", "football", "club_members", 110_000, "110.000 Mitglieder", "Großer Verein aus dem Norden")
        add("VfB Stuttgart", "Stuttgart", "football", "club_members", 100_000, "100.000 Mitglieder", "Traditionsclub im Südwesten")
        add("Borussia Mönchengladbach", "Mönchengladbach", "football", "club_members", 95_000, "95.000 Mitglieder", "Fohlen-Anhängerschaft am Niederrhein")
        add("Hertha BSC", "Berlin", "football", "club_members", 53_000, "53.000 Mitglieder", "Hauptstadtclub mit langer Geschichte")
        add("FC St. Pauli", "Hamburg", "football", "club_members", 47_000, "47.000 Mitglieder", "Kiez-Club mit weltweiter Anhängerschaft")
        add("Werder Bremen", "Bremen", "football", "club_members", 48_000, "48.000 Mitglieder", "Grün-weißer Traditionsverein")
        add("1. FC Nürnberg", "Nürnberg", "football", "club_members", 34_000, "34.000 Mitglieder", "Der Club aus Franken")
        add("1. FSV Mainz 05", "Mainz", "football", "club_members", 26_000, "26.000 Mitglieder", "Karneval und Bundesliga in einem Verein")
        add("Fortuna Düsseldorf", "Düsseldorf", "football", "club_members", 22_000, "22.000 Mitglieder", "Rheinländischer Zweitligist")
        add("SC Freiburg", "Freiburg", "football", "club_members", 24_000, "24.000 Mitglieder", "Stabiler Verein im Breisgau")
        add("VfL Bochum", "Bochum", "football", "club_members", 12_000, "12.000 Mitglieder", "Ruhrpott-Verein mit treuer Basis")
        add("Karlsruher SC", "Karlsruhe", "football", "club_members", 18_000, "18.000 Mitglieder", "Tradition aus Baden")
        add("Eintracht Braunschweig", "Braunschweig", "football", "club_members", 15_000, "15.000 Mitglieder", "Erster deutscher Meister 1967")
        add("1. FC Kaiserslautern", "Kaiserslautern", "football", "club_members", 21_000, "21.000 Mitglieder", "Roter Teufel von Betzenberg")
        add("Bayer 04 Leverkusen", "Leverkusen", "football", "club_members", 33_000, "33.000 Mitglieder", "Werksclub mit wachsender Mitgliederzahl")

        // ============================================================
        // FOOTBALL — Instagram-Follower (Vereinsaccounts)
        // ============================================================
        add("FC Bayern München", "Fußballclub", "football", "instagram_followers", 42_000_000, "42 Mio. Follower", "International sehr sichtbarer Club")
        add("Borussia Dortmund", "Fußballclub", "football", "instagram_followers", 21_000_000, "21 Mio. Follower", "Große internationale Fanbase")
        add("DFB-Team", "Nationalmannschaft", "football", "instagram_followers", 12_500_000, "12,5 Mio. Follower", "Die Mannschaft auf Instagram")
        add("RB Leipzig", "Fußballclub", "football", "instagram_followers", 4_200_000, "4,2 Mio. Follower", "Junge Marke mit globalem Auftritt")
        add("Bayer 04 Leverkusen", "Fußballclub", "football", "instagram_followers", 3_500_000, "3,5 Mio. Follower", "Reichweite seit Double 2024")
        add("FC Schalke 04", "Fußballclub", "football", "instagram_followers", 2_100_000, "2,1 Mio. Follower", "Königsblauer Account")
        add("Eintracht Frankfurt", "Fußballclub", "football", "instagram_followers", 1_900_000, "1,9 Mio. Follower", "Adler mit aktiver Content-Strategie")
        add("Hamburger SV", "Fußballclub", "football", "instagram_followers", 1_500_000, "1,5 Mio. Follower", "Bundesliga-Dino auf Instagram")
        add("VfB Stuttgart", "Fußballclub", "football", "instagram_followers", 1_400_000, "1,4 Mio. Follower", "Schwabenclub in Social Media")
        add("FC St. Pauli", "Fußballclub", "football", "instagram_followers", 1_300_000, "1,3 Mio. Follower", "Kultmarke mit weltweiter Resonanz")
        add("1. FC Köln", "Fußballclub", "football", "instagram_followers", 1_100_000, "1,1 Mio. Follower", "Geißbock-Reichweite")
        add("Hertha BSC", "Fußballclub", "football", "instagram_followers", 1_000_000, "1 Mio. Follower", "Hauptstadtclub auf Instagram")
        add("Werder Bremen", "Fußballclub", "football", "instagram_followers", 880_000, "880 Tsd. Follower", "Grün-weißer Account")
        add("Borussia Mönchengladbach", "Fußballclub", "football", "instagram_followers", 800_000, "800 Tsd. Follower", "Fohlen in den sozialen Medien")
        add("1. FC Union Berlin", "Fußballclub", "football", "instagram_followers", 650_000, "650 Tsd. Follower", "Köpenicker Reichweite")
        add("VfL Wolfsburg", "Fußballclub", "football", "instagram_followers", 540_000, "540 Tsd. Follower", "Werksclub mit globalem VW-Bezug")
        add("TSG 1899 Hoffenheim", "Fußballclub", "football", "instagram_followers", 470_000, "470 Tsd. Follower", "Internationaler Auftritt")
        add("SC Freiburg", "Fußballclub", "football", "instagram_followers", 430_000, "430 Tsd. Follower", "Sympathisch wachsende Reichweite")
        add("1. FSV Mainz 05", "Fußballclub", "football", "instagram_followers", 360_000, "360 Tsd. Follower", "Karnevalsfans auf Instagram")
        add("FC Augsburg", "Fußballclub", "football", "instagram_followers", 250_000, "250 Tsd. Follower", "Schwäbische Reichweite")

        // ============================================================
        // FOOTBALL — Titel (Deutsche Meisterschaften + DFB-Pokalsiege)
        // ============================================================
        add("FC Bayern München", "München", "football", "titles", 53, "53 Titel", "33 Meisterschaften + 20 DFB-Pokal")
        add("1. FC Nürnberg", "Nürnberg", "football", "titles", 13, "13 Titel", "9 Meisterschaften + 4 DFB-Pokal")
        add("Borussia Dortmund", "Dortmund", "football", "titles", 13, "13 Titel", "8 Meisterschaften + 5 DFB-Pokal")
        add("FC Schalke 04", "Gelsenkirchen", "football", "titles", 12, "12 Titel", "7 Meisterschaften + 5 DFB-Pokal")
        add("Werder Bremen", "Bremen", "football", "titles", 10, "10 Titel", "4 Meisterschaften + 6 DFB-Pokal")
        add("Hamburger SV", "Hamburg", "football", "titles", 9, "9 Titel", "6 Meisterschaften + 3 DFB-Pokal")
        add("Borussia Mönchengladbach", "Mönchengladbach", "football", "titles", 8, "8 Titel", "5 Meisterschaften + 3 DFB-Pokal")
        add("VfB Stuttgart", "Stuttgart", "football", "titles", 8, "8 Titel", "5 Meisterschaften + 3 DFB-Pokal")
        add("1. FC Köln", "Köln", "football", "titles", 7, "7 Titel", "3 Meisterschaften + 4 DFB-Pokal")
        add("Eintracht Frankfurt", "Frankfurt", "football", "titles", 6, "6 Titel", "1 Meisterschaft + 5 DFB-Pokal")
        add("1. FC Kaiserslautern", "Kaiserslautern", "football", "titles", 6, "6 Titel", "4 Meisterschaften + 2 DFB-Pokal")
        add("Bayer 04 Leverkusen", "Leverkusen", "football", "titles", 3, "3 Titel", "Double-Sieger 2024")
        add("Hannover 96", "Hannover", "football", "titles", 3, "3 Titel", "2 Meisterschaften + 1 DFB-Pokal")
        add("Hertha BSC", "Berlin", "football", "titles", 2, "2 Titel", "Meister 1930 und 1931")
        add("RB Leipzig", "Leipzig", "football", "titles", 3, "3 Titel", "Dreimaliger DFB-Pokalsieger")
        add("VfL Wolfsburg", "Wolfsburg", "football", "titles", 2, "2 Titel", "Meister 2009 und DFB-Pokal 2015")
        add("VfL Bochum", "Bochum", "football", "titles", 0, "0 Titel", "Noch ohne nationalen Titel")
        add("FC St. Pauli", "Hamburg", "football", "titles", 0, "0 Titel", "Kultclub ohne nationalen Titel")
        add("SC Freiburg", "Freiburg", "football", "titles", 0, "0 Titel", "DFB-Pokal-Finalist 2022")
        add("1. FSV Mainz 05", "Mainz", "football", "titles", 0, "0 Titel", "Noch ohne nationalen Titel")

        // ============================================================
        // FOOTBALL — Zuschauerschnitt (durchschnittliche Heimzuschauer pro Saison)
        // ============================================================
        add("Borussia Dortmund", "Dortmund", "football", "attendance", 81_200, "81.200 Zuschauer", "Höchster Schnitt Europas")
        add("FC Bayern München", "München", "football", "attendance", 75_000, "75.000 Zuschauer", "Allianz Arena fast immer voll")
        add("FC Schalke 04", "Gelsenkirchen", "football", "attendance", 61_000, "61.000 Zuschauer", "Königsblauer Heimrekord")
        add("VfB Stuttgart", "Stuttgart", "football", "attendance", 59_000, "59.000 Zuschauer", "Schwäbische Heimstärke")
        add("Eintracht Frankfurt", "Frankfurt", "football", "attendance", 57_500, "57.500 Zuschauer", "Adler-Heimspielatmosphäre")
        add("Hamburger SV", "Hamburg", "football", "attendance", 56_500, "56.500 Zuschauer", "Treue Fanbasis im Volkspark")
        add("Borussia Mönchengladbach", "Mönchengladbach", "football", "attendance", 51_400, "51.400 Zuschauer", "Fohlen vor vollem Haus")
        add("Hertha BSC", "Berlin", "football", "attendance", 50_500, "50.500 Zuschauer", "Hauptstadt-Heimspielkulisse")
        add("1. FC Köln", "Köln", "football", "attendance", 49_500, "49.500 Zuschauer", "Geißbock-Heimspielwucht")
        add("RB Leipzig", "Leipzig", "football", "attendance", 46_500, "46.500 Zuschauer", "Solide Auslastung in Sachsen")
        add("Werder Bremen", "Bremen", "football", "attendance", 41_800, "41.800 Zuschauer", "Weserstadion gut gefüllt")
        add("SC Freiburg", "Freiburg", "football", "attendance", 34_500, "34.500 Zuschauer", "Volle Hütte im Europa-Park-Stadion")
        add("MEWA ARENA Mainz", "1. FSV Mainz 05", "football", "attendance", 31_200, "31.200 Zuschauer", "Stabiler Bundesligaschnitt")
        add("Bayer 04 Leverkusen", "Leverkusen", "football", "attendance", 30_200, "30.200 Zuschauer", "BayArena oft ausverkauft")
        add("1. FC Union Berlin", "Berlin", "football", "attendance", 22_000, "22.000 Zuschauer", "Köpenick fast immer voll")
        add("VfL Wolfsburg", "Wolfsburg", "football", "attendance", 25_800, "25.800 Zuschauer", "Werksclub-Heimspielschnitt")
        add("FC Augsburg", "Augsburg", "football", "attendance", 26_500, "26.500 Zuschauer", "Schwäbische Heimspielkulisse")
        add("FC St. Pauli", "Hamburg", "football", "attendance", 29_500, "29.500 Zuschauer", "Millerntor immer ausverkauft")
        add("VfL Bochum", "Bochum", "football", "attendance", 25_500, "25.500 Zuschauer", "Vonovia Ruhrstadion gut besucht")
        add("1. FC Heidenheim", "Heidenheim", "football", "attendance", 14_500, "14.500 Zuschauer", "Kleine Voith-Arena maximal genutzt")
        add("Holstein Kiel", "Kiel", "football", "attendance", 14_900, "14.900 Zuschauer", "Holstein-Stadion nahe an der Kapazitätsgrenze")
        add("SV Darmstadt 98", "Darmstadt", "football", "attendance", 17_500, "17.500 Zuschauer", "Das Böllenfalltor ist oft sehr gut gefüllt")
        add("SC Paderborn 07", "Paderborn", "football", "attendance", 14_400, "14.400 Zuschauer", "Kompakte Arena mit hoher Auslastung")
        add("1. FC Magdeburg", "Magdeburg", "football", "attendance", 25_300, "25.300 Zuschauer", "Sehr starke Heimkulisse in der Avnet Arena")
        add("SV Elversberg", "Spiesen-Elversberg", "football", "attendance", 9_300, "9.300 Zuschauer", "Kleine Arena mit hoher Auslastung")
        add("Arminia Bielefeld", "Bielefeld", "football", "attendance", 20_000, "20.000 Zuschauer", "Die Alm bringt auch unterhalb der Bundesliga viele Fans")
        add("SpVgg Greuther Fürth", "Fürth", "football", "attendance", 11_500, "11.500 Zuschauer", "Der Ronhof bleibt eng und traditionsreich")
        add("SSV Ulm 1846", "Ulm", "football", "attendance", 13_000, "13.000 Zuschauer", "Donaustadion mit wachsender Zweitliga-Kulisse")

        // ============================================================
        // GERMANY — Einwohnerzahlen (Städte)
        // ============================================================
        add("Berlin", "Hauptstadt", "germany", "population", 3_755_000, "3,76 Mio.", "Deutschlands größte Stadt")
        add("Hamburg", "Hansestadt", "germany", "population", 1_892_000, "1,89 Mio.", "Stadt an Elbe und Alster")
        add("München", "Bayern", "germany", "population", 1_512_000, "1,51 Mio.", "Drittgrößte Stadt Deutschlands")
        add("Köln", "Nordrhein-Westfalen", "germany", "population", 1_084_000, "1,08 Mio.", "Domstadt am Rhein")
        add("Frankfurt am Main", "Hessen", "germany", "population", 773_000, "773.000", "Finanzzentrum Deutschlands")
        add("Stuttgart", "Baden-Württemberg", "germany", "population", 633_000, "633.000", "Autostadt im Kessel")
        add("Düsseldorf", "Nordrhein-Westfalen", "germany", "population", 629_000, "629.000", "Landeshauptstadt am Rhein")
        add("Leipzig", "Sachsen", "germany", "population", 616_000, "616.000", "Wachsende Messestadt")
        add("Dortmund", "Nordrhein-Westfalen", "germany", "population", 594_000, "594.000", "Großstadt im Ruhrgebiet")
        add("Essen", "Nordrhein-Westfalen", "germany", "population", 584_000, "584.000", "Zentrum des Ruhrgebiets")
        add("Bremen", "Hansestadt", "germany", "population", 567_000, "567.000", "Hansestadt an der Weser")
        add("Dresden", "Sachsen", "germany", "population", 564_000, "564.000", "Elbflorenz mit Frauenkirche")
        add("Hannover", "Niedersachsen", "germany", "population", 545_000, "545.000", "Landeshauptstadt von Niedersachsen")
        add("Nürnberg", "Bayern", "germany", "population", 524_000, "524.000", "Größte Stadt Frankens")
        add("Duisburg", "Nordrhein-Westfalen", "germany", "population", 510_000, "510.000", "Größter Binnenhafen Europas")
        add("Bochum", "Nordrhein-Westfalen", "germany", "population", 365_000, "365.000", "Universitätsstadt im Ruhrgebiet")
        add("Wuppertal", "Nordrhein-Westfalen", "germany", "population", 360_000, "360.000", "Heimat der Schwebebahn")
        add("Bielefeld", "Nordrhein-Westfalen", "germany", "population", 339_000, "339.000", "Größte Stadt Ostwestfalens")
        add("Bonn", "Nordrhein-Westfalen", "germany", "population", 339_000, "339.000", "Ehemalige Bundeshauptstadt")
        add("Münster", "Nordrhein-Westfalen", "germany", "population", 322_000, "322.000", "Fahrradstadt im Münsterland")

        // ============================================================
        // GERMANY — Fläche (Bundesländer in km²)
        // ============================================================
        add("Bayern", "Bundesland", "germany", "area", 70_542, "70.542 km²", "Größtes deutsches Bundesland")
        add("Niedersachsen", "Bundesland", "germany", "area", 47_710, "47.710 km²", "Flächenland im Norden")
        add("Baden-Württemberg", "Bundesland", "germany", "area", 35_751, "35.751 km²", "Südwesten Deutschlands")
        add("Nordrhein-Westfalen", "Bundesland", "germany", "area", 34_112, "34.112 km²", "Bevölkerungsreichstes Bundesland")
        add("Brandenburg", "Bundesland", "germany", "area", 29_654, "29.654 km²", "Umschließt Berlin")
        add("Mecklenburg-Vorpommern", "Bundesland", "germany", "area", 23_295, "23.295 km²", "Land an der Ostsee")
        add("Hessen", "Bundesland", "germany", "area", 21_116, "21.116 km²", "Bundesland in der Mitte")
        add("Sachsen-Anhalt", "Bundesland", "germany", "area", 20_452, "20.452 km²", "Flächenland im Osten")
        add("Rheinland-Pfalz", "Bundesland", "germany", "area", 19_858, "19.858 km²", "Weinland am Rhein")
        add("Sachsen", "Bundesland", "germany", "area", 18_450, "18.450 km²", "Freistaat im Osten")
        add("Thüringen", "Bundesland", "germany", "area", 16_202, "16.202 km²", "Grünes Herz Deutschlands")
        add("Schleswig-Holstein", "Bundesland", "germany", "area", 15_804, "15.804 km²", "Land zwischen den Meeren")
        add("Saarland", "Bundesland", "germany", "area", 2_571, "2.571 km²", "Kleinstes Flächenland")
        add("Berlin", "Bundesland", "germany", "area", 891, "891 km²", "Stadtstaat und Hauptstadt")
        add("Hamburg", "Bundesland", "germany", "area", 755, "755 km²", "Stadtstaat im Norden")
        add("Bremen", "Bundesland", "germany", "area", 419, "419 km²", "Kleinstes Bundesland")
        add("Köln", "Stadtgebiet", "germany", "area", 405, "405 km²", "Größte Stadt NRWs nach Fläche")
        add("München", "Stadtgebiet", "germany", "area", 311, "311 km²", "Bayerische Landeshauptstadt")
        add("Frankfurt am Main", "Stadtgebiet", "germany", "area", 248, "248 km²", "Mainmetropole")
        add("Stuttgart", "Stadtgebiet", "germany", "area", 207, "207 km²", "Schwäbische Metropole")

        // ============================================================
        // GERMANY — Mieten (€/m² als Cent, displayValue zeigt Euro)
        // ============================================================
        add("München", "Mietmarkt", "germany", "rent", 2_250, "22,50 €/m²", "Einer der teuersten Mietmärkte")
        add("Frankfurt am Main", "Mietmarkt", "germany", "rent", 1_850, "18,50 €/m²", "Hohe Nachfrage im Bankenviertel")
        add("Berlin", "Mietmarkt", "germany", "rent", 1_750, "17,50 €/m²", "Stark umkämpfter Wohnungsmarkt")
        add("Hamburg", "Mietmarkt", "germany", "rent", 1_650, "16,50 €/m²", "Teure Lagen an Alster und Elbe")
        add("Stuttgart", "Mietmarkt", "germany", "rent", 1_620, "16,20 €/m²", "Knapper Wohnraum im Talkessel")
        add("Düsseldorf", "Mietmarkt", "germany", "rent", 1_480, "14,80 €/m²", "Beliebte Rheinmetropole")
        add("Köln", "Mietmarkt", "germany", "rent", 1_430, "14,30 €/m²", "Hohe Nachfrage in Uninähe")
        add("Leipzig", "Mietmarkt", "germany", "rent", 1_050, "10,50 €/m²", "Weiterhin günstiger als viele Metropolen")
        add("Dortmund", "Mietmarkt", "germany", "rent", 920, "9,20 €/m²", "Ruhrgebiet mit moderateren Preisen")
        add("Dresden", "Mietmarkt", "germany", "rent", 980, "9,80 €/m²", "Attraktive Stadt an der Elbe")
        add("Mainz", "Mietmarkt", "germany", "rent", 1_280, "12,80 €/m²", "Universitätsstadt am Rhein")
        add("Bonn", "Mietmarkt", "germany", "rent", 1_290, "12,90 €/m²", "Ehemalige Bundeshauptstadt")
        add("Heidelberg", "Mietmarkt", "germany", "rent", 1_450, "14,50 €/m²", "Beliebte Studierendenstadt")
        add("Freiburg im Breisgau", "Mietmarkt", "germany", "rent", 1_450, "14,50 €/m²", "Sonnenreichste Großstadt")
        add("Münster", "Mietmarkt", "germany", "rent", 1_310, "13,10 €/m²", "Westfälische Fahrradmetropole")
        add("Karlsruhe", "Mietmarkt", "germany", "rent", 1_240, "12,40 €/m²", "Fächerstadt in Baden")
        add("Augsburg", "Mietmarkt", "germany", "rent", 1_310, "13,10 €/m²", "Drittgrößte Stadt Bayerns")
        add("Regensburg", "Mietmarkt", "germany", "rent", 1_320, "13,20 €/m²", "UNESCO-Welterbe an der Donau")
        add("Erlangen", "Mietmarkt", "germany", "rent", 1_450, "14,50 €/m²", "Siemens-Stadt in Franken")
        add("Nürnberg", "Mietmarkt", "germany", "rent", 1_240, "12,40 €/m²", "Größte Stadt Frankens")

        // ============================================================
        // GERMANY — Durchschnittsgehalt (Brutto-Jahresgehalt in €)
        // ============================================================
        add("München", "Stadt", "germany", "salary", 58_000, "58.000 €", "Höchste Durchschnittsgehälter Deutschlands")
        add("Erlangen", "Stadt", "germany", "salary", 57_500, "57.500 €", "Industriestandort mit hohen Gehältern")
        add("Ingolstadt", "Stadt", "germany", "salary", 57_000, "57.000 €", "Audi-Stadt in Bayern")
        add("Frankfurt am Main", "Stadt", "germany", "salary", 57_000, "57.000 €", "Hochlohnstandort im Bankenviertel")
        add("Stuttgart", "Stadt", "germany", "salary", 56_000, "56.000 €", "Hohe Gehälter in Automobilbranche")
        add("Düsseldorf", "Stadt", "germany", "salary", 54_000, "54.000 €", "Wirtschaftsstandort am Rhein")
        add("Hamburg", "Stadt", "germany", "salary", 53_000, "53.000 €", "Medien- und Logistikbranche")
        add("Wolfsburg", "Stadt", "germany", "salary", 52_500, "52.500 €", "VW-Werksstadt")
        add("Bonn", "Stadt", "germany", "salary", 52_500, "52.500 €", "DAX-Konzern Telekom und Deutsche Post")
        add("Wiesbaden", "Stadt", "germany", "salary", 52_000, "52.000 €", "Landeshauptstadt von Hessen")
        add("Köln", "Stadt", "germany", "salary", 51_000, "51.000 €", "Medienstadt am Rhein")
        add("Heidelberg", "Stadt", "germany", "salary", 50_500, "50.500 €", "Forschungsstandort mit SAP-Nähe")
        add("Berlin", "Stadt", "germany", "salary", 50_500, "50.500 €", "Hauptstadt mit steigenden Gehältern")
        add("Karlsruhe", "Stadt", "germany", "salary", 50_500, "50.500 €", "Tech-Standort in Baden")
        add("Mainz", "Stadt", "germany", "salary", 50_000, "50.000 €", "BioNTech und Schott AG")
        add("Nürnberg", "Stadt", "germany", "salary", 48_000, "48.000 €", "Wirtschaftszentrum Mittelfrankens")
        add("Hannover", "Stadt", "germany", "salary", 48_500, "48.500 €", "Messestadt mit Continental-Sitz")
        add("Münster", "Stadt", "germany", "salary", 47_500, "47.500 €", "Universitäts- und Verwaltungsstadt")
        add("Bremen", "Stadt", "germany", "salary", 46_500, "46.500 €", "Hansestadt mit Airbus und Mercedes")
        add("Leipzig", "Stadt", "germany", "salary", 44_500, "44.500 €", "Wachsende Wirtschaft in Sachsen")
        add("Dresden", "Stadt", "germany", "salary", 45_000, "45.000 €", "Halbleiterstandort 'Silicon Saxony'")

        // ============================================================
        // GERMANY — Touristen (Übernachtungen pro Jahr)
        // ============================================================
        add("Berlin", "Hauptstadt", "germany", "tourists", 30_000_000, "30 Mio. Übernachtungen", "Tourismusmagnet Nummer eins")
        add("München", "Bayern", "germany", "tourists", 18_500_000, "18,5 Mio. Übernachtungen", "Oktoberfest und Altstadt")
        add("Hamburg", "Hansestadt", "germany", "tourists", 16_000_000, "16 Mio. Übernachtungen", "Hafen und Elbphilharmonie")
        add("Frankfurt am Main", "Hessen", "germany", "tourists", 10_500_000, "10,5 Mio. Übernachtungen", "Geschäftsreisen und Messen")
        add("Köln", "NRW", "germany", "tourists", 8_000_000, "8 Mio. Übernachtungen", "Dom und Karneval")
        add("Rügen", "Mecklenburg-Vorpommern", "germany", "tourists", 7_000_000, "7 Mio. Übernachtungen", "Größte Ostseeinsel Deutschlands")
        add("Düsseldorf", "NRW", "germany", "tourists", 5_500_000, "5,5 Mio. Übernachtungen", "Mode- und Messemetropole")
        add("Dresden", "Sachsen", "germany", "tourists", 4_600_000, "4,6 Mio. Übernachtungen", "Frauenkirche und Semperoper")
        add("Stuttgart", "Baden-Württemberg", "germany", "tourists", 4_000_000, "4 Mio. Übernachtungen", "Cannstatter Wasen und Automuseen")
        add("Nürnberg", "Bayern", "germany", "tourists", 3_500_000, "3,5 Mio. Übernachtungen", "Christkindlesmarkt und Burg")
        add("Leipzig", "Sachsen", "germany", "tourists", 3_400_000, "3,4 Mio. Übernachtungen", "Messestadt mit lebendiger Szene")
        add("Hannover", "Niedersachsen", "germany", "tourists", 2_500_000, "2,5 Mio. Übernachtungen", "Messeplatz und Herrenhäuser Gärten")
        add("Bremen", "Bremen", "germany", "tourists", 2_100_000, "2,1 Mio. Übernachtungen", "Stadtmusikanten und Schnoor")
        add("Garmisch-Partenkirchen", "Bayern", "germany", "tourists", 2_000_000, "2 Mio. Übernachtungen", "Alpiner Wintersportort")
        add("Heidelberg", "Baden-Württemberg", "germany", "tourists", 1_600_000, "1,6 Mio. Übernachtungen", "Schloss und Altstadt")
        add("Freiburg im Breisgau", "Baden-Württemberg", "germany", "tourists", 1_500_000, "1,5 Mio. Übernachtungen", "Tor zum Schwarzwald")
        add("Bonn", "NRW", "germany", "tourists", 1_400_000, "1,4 Mio. Übernachtungen", "Beethoven-Stadt am Rhein")
        add("Trier", "Rheinland-Pfalz", "germany", "tourists", 1_300_000, "1,3 Mio. Übernachtungen", "Älteste Stadt Deutschlands")
        add("Mainz", "Rheinland-Pfalz", "germany", "tourists", 900_000, "900 Tsd. Übernachtungen", "Dom und Gutenberg-Museum")
        add("Rothenburg ob der Tauber", "Bayern", "germany", "tourists", 500_000, "500 Tsd. Übernachtungen", "Mittelalterliche Altstadt")

        // ============================================================
        // GERMANY — Bierkonsum (Pro-Kopf-Verbrauch in Litern pro Jahr, Bundesländer & Marken)
        // ============================================================
        add("Bayern", "Bundesland", "germany", "beer_consumption", 135, "135 l/Kopf", "Spitzenreiter beim Bierkonsum")
        add("Thüringen", "Bundesland", "germany", "beer_consumption", 110, "110 l/Kopf", "Hoher Pro-Kopf-Verbrauch")
        add("Niedersachsen", "Bundesland", "germany", "beer_consumption", 105, "105 l/Kopf", "Heimat vieler Brauereien")
        add("Baden-Württemberg", "Bundesland", "germany", "beer_consumption", 102, "102 l/Kopf", "Schwäbisch-badische Biertradition")
        add("Brandenburg", "Bundesland", "germany", "beer_consumption", 100, "100 l/Kopf", "Pils-Hochburg")
        add("Sachsen-Anhalt", "Bundesland", "germany", "beer_consumption", 100, "100 l/Kopf", "Hasseröder und Co.")
        add("Mecklenburg-Vorpommern", "Bundesland", "germany", "beer_consumption", 100, "100 l/Kopf", "Ostsee-Biere")
        add("Schleswig-Holstein", "Bundesland", "germany", "beer_consumption", 100, "100 l/Kopf", "Flensburger Pilsener")
        add("Rheinland-Pfalz", "Bundesland", "germany", "beer_consumption", 95, "95 l/Kopf", "Bitburger-Heimat")
        add("Saarland", "Bundesland", "germany", "beer_consumption", 95, "95 l/Kopf", "Karlsberg-Brauerei")
        add("Berlin", "Stadtstaat", "germany", "beer_consumption", 95, "95 l/Kopf", "Berliner Pilsner und Biermischungen")
        add("Nordrhein-Westfalen", "Bundesland", "germany", "beer_consumption", 95, "95 l/Kopf", "Kölsch und Alt")
        add("Hessen", "Bundesland", "germany", "beer_consumption", 92, "92 l/Kopf", "Apfelwein-Konkurrenz")
        add("Sachsen", "Bundesland", "germany", "beer_consumption", 90, "90 l/Kopf", "Radeberger Pilsner")
        add("Bremen", "Stadtstaat", "germany", "beer_consumption", 90, "90 l/Kopf", "Beck's-Stammsitz")
        add("Hamburg", "Stadtstaat", "germany", "beer_consumption", 85, "85 l/Kopf", "Astra und Holsten")
        add("Deutschland", "Durchschnitt", "germany", "beer_consumption", 88, "88 l/Kopf", "Bundesdurchschnitt 2024")
        add("Oktoberfest München", "Veranstaltung", "germany", "beer_consumption", 7_000_000, "7 Mio. Liter", "Bierausschank während des Festes")
        add("Cannstatter Wasen", "Veranstaltung", "germany", "beer_consumption", 1_500_000, "1,5 Mio. Liter", "Stuttgarter Volksfest")
        add("Krombacher", "Brauerei", "germany", "beer_consumption", 650_000_000, "650 Mio. Liter", "Ausstoß pro Jahr (in Litern)")

        // ============================================================
        // CARS — Preis
        // ============================================================
        add("VW Golf GTI", "Kompaktsportler", "cars", "price", 44_500, "44.500 €", "Klassiker der Kompaktklasse")
        add("BMW M3 Touring", "Sportkombi", "cars", "price", 105_300, "105.300 €", "Performance-Kombi aus München")
        add("Porsche 911 Carrera", "Sportwagen", "cars", "price", 128_700, "128.700 €", "Ikone aus Zuffenhausen")
        add("Mercedes-Benz G 500", "Geländewagen", "cars", "price", 130_200, "130.200 €", "Luxus-Offroader")
        add("Audi RS 6 Avant", "Sportkombi", "cars", "price", 132_000, "132.000 €", "Schneller Kombi aus Ingolstadt")
        add("Opel Astra", "Kompaktwagen", "cars", "price", 27_000, "27.000 €", "Volumenmodell aus Rüsselsheim")
        add("VW ID.3 Pro", "Elektroauto", "cars", "price", 39_900, "39.900 €", "Elektrischer Kompaktwagen")
        add("BMW i5 M60", "Elektrolimousine", "cars", "price", 99_500, "99.500 €", "Elektrische Businessklasse")
        add("Mercedes-AMG A 45 S", "Kompaktsportler", "cars", "price", 73_000, "73.000 €", "Starker Kompakt-AMG")
        add("Porsche Taycan", "Elektrosportwagen", "cars", "price", 101_500, "101.500 €", "Sportlicher Elektro-Porsche")
        add("Audi A4", "Limousine", "cars", "price", 45_000, "45.000 €", "Mittelklasse aus Ingolstadt")
        add("Mercedes C 300", "Limousine", "cars", "price", 55_000, "55.000 €", "Premium-Mittelklasse")
        add("BMW 320i", "Limousine", "cars", "price", 47_500, "47.500 €", "Klassiker der Businessklasse")
        add("VW Tiguan", "SUV", "cars", "price", 37_000, "37.000 €", "Bestseller-SUV von VW")
        add("Skoda Octavia", "Kombi", "cars", "price", 28_500, "28.500 €", "Vielseitiger Familienwagen")
        add("Ford Focus", "Kompaktwagen", "cars", "price", 26_000, "26.000 €", "Volumenmodell aus Köln")
        add("Tesla Model 3", "Elektrolimousine", "cars", "price", 42_000, "42.000 €", "Globale E-Auto-Ikone")
        add("Mercedes EQS 580", "Elektrolimousine", "cars", "price", 137_000, "137.000 €", "Elektrische Oberklasse")
        add("BMW X5 xDrive40i", "SUV", "cars", "price", 82_000, "82.000 €", "Premium-SUV aus München")
        add("Audi Q5", "SUV", "cars", "price", 55_000, "55.000 €", "Mittelklasse-SUV aus Ingolstadt")
        add("Porsche Cayenne", "SUV", "cars", "price", 97_500, "97.500 €", "Sport-SUV aus Zuffenhausen")
        add("VW Polo TSI", "Kleinwagen", "cars", "price", 22_500, "22.500 €", "Kleinwagen-Klassiker")
        add("Smart #1", "Elektroauto", "cars", "price", 38_500, "38.500 €", "Elektrischer Crossover")

        // ============================================================
        // CARS — PS
        // ============================================================
        add("VW Golf GTI", "Kompaktsportler", "cars", "horsepower", 265, "265 PS", "Seit Jahrzehnten ein GTI-Maßstab")
        add("BMW M3 Touring", "Sportkombi", "cars", "horsepower", 510, "510 PS", "M-Modell mit Kombiheck")
        add("Porsche 911 Carrera", "Sportwagen", "cars", "horsepower", 394, "394 PS", "Boxermotor im Heck")
        add("Mercedes-Benz G 500", "Geländewagen", "cars", "horsepower", 449, "449 PS", "Kraftvoller Luxus-Offroader")
        add("Audi RS 6 Avant performance", "Sportkombi", "cars", "horsepower", 630, "630 PS", "Extrem schneller Alltagskombi")
        add("Opel Astra GSe", "Plug-in-Hybrid", "cars", "horsepower", 225, "225 PS", "Sportlicher Astra-Hybrid")
        add("VW ID.3 Pro", "Elektroauto", "cars", "horsepower", 204, "204 PS", "Elektrischer Kompaktwagen")
        add("BMW i5 M60", "Elektrolimousine", "cars", "horsepower", 601, "601 PS", "Elektrischer Allradantrieb")
        add("Mercedes-AMG A 45 S", "Kompaktsportler", "cars", "horsepower", 421, "421 PS", "Sehr leistungsstarker Vierzylinder")
        add("Porsche Taycan Turbo GT", "Elektrosportwagen", "cars", "horsepower", 1_034, "1.034 PS", "Topmodell der Taycan-Reihe")
        add("Audi A4 40 TFSI", "Limousine", "cars", "horsepower", 204, "204 PS", "Mittelklasse-Benziner")
        add("Mercedes C 300", "Limousine", "cars", "horsepower", 258, "258 PS", "Mild-Hybrid mit starkem Antritt")
        add("BMW 330i", "Limousine", "cars", "horsepower", 245, "245 PS", "Reihensechser-Tradition")
        add("VW Tiguan 2.0 TDI", "SUV", "cars", "horsepower", 150, "150 PS", "Diesel-SUV für die Familie")
        add("Skoda Octavia RS", "Kombi", "cars", "horsepower", 265, "265 PS", "Vielseitiger Sportkombi")
        add("Ford Focus ST", "Kompaktwagen", "cars", "horsepower", 280, "280 PS", "Kölner Hot-Hatch")
        add("Tesla Model 3 Performance", "Elektrolimousine", "cars", "horsepower", 510, "510 PS", "Allrad mit zwei Motoren")
        add("Mercedes EQS 580", "Elektrolimousine", "cars", "horsepower", 523, "523 PS", "Elektrische Oberklasse")
        add("BMW M5", "Sportlimousine", "cars", "horsepower", 727, "727 PS", "Plug-in-Hybrid mit V8")
        add("Porsche 911 Turbo S", "Sportwagen", "cars", "horsepower", 650, "650 PS", "Allrad-Sportwagen")
        add("Audi RS Q8", "SUV", "cars", "horsepower", 600, "600 PS", "Performance-SUV mit V8")
        add("Mercedes-AMG GT 63 S", "Sportcoupe", "cars", "horsepower", 639, "639 PS", "4-Türer-Coupé von AMG")
        add("VW Polo GTI", "Kleinwagen", "cars", "horsepower", 207, "207 PS", "Kleiner GTI")

        // ============================================================
        // CARS — Höchstgeschwindigkeit (km/h)
        // ============================================================
        add("Mercedes-AMG One", "Hypercar", "cars", "top_speed", 352, "352 km/h", "F1-Technik für die Straße")
        add("Porsche 918 Spyder", "Hypercar", "cars", "top_speed", 345, "345 km/h", "Hybrid-Sportwagen aus Zuffenhausen")
        add("Porsche 911 Turbo S", "Sportwagen", "cars", "top_speed", 330, "330 km/h", "Allrad-Power aus Stuttgart")
        add("Tesla Model S Plaid", "Elektrolimousine", "cars", "top_speed", 322, "322 km/h", "Schnellste E-Limousine")
        add("Mercedes-AMG GT 63 S", "Sportcoupe", "cars", "top_speed", 315, "315 km/h", "4-Türer-Coupé von AMG")
        add("Audi RS 6 Avant performance", "Sportkombi", "cars", "top_speed", 305, "305 km/h", "Optional ohne Begrenzung")
        add("Audi RS Q8", "SUV", "cars", "top_speed", 305, "305 km/h", "Performance-SUV mit V8")
        add("BMW M5", "Sportlimousine", "cars", "top_speed", 305, "305 km/h", "Plug-in-Hybrid mit V8")
        add("Porsche Taycan Turbo GT", "Elektrosportwagen", "cars", "top_speed", 305, "305 km/h", "Schnellster Serien-Taycan")
        add("Porsche 911 Carrera", "Sportwagen", "cars", "top_speed", 294, "294 km/h", "Klassischer Boxer-Sportler")
        add("BMW M3 Touring", "Sportkombi", "cars", "top_speed", 280, "280 km/h", "M-Modell mit Kombiheck")
        add("VW Touareg R", "SUV", "cars", "top_speed", 250, "250 km/h", "Allrad-SUV mit Hybridantrieb")
        add("VW Golf GTI", "Kompaktsportler", "cars", "top_speed", 250, "250 km/h", "Klassiker der Kompaktklasse")
        add("Opel Astra GSe", "Plug-in-Hybrid", "cars", "top_speed", 235, "235 km/h", "Sportlicher Astra-Hybrid")
        add("BMW i5 M60", "Elektrolimousine", "cars", "top_speed", 230, "230 km/h", "Elektrische Businessklasse")
        add("Mercedes EQS 580", "Elektrolimousine", "cars", "top_speed", 210, "210 km/h", "Begrenzte Höchstgeschwindigkeit")
        add("Mercedes-Benz G 500", "Geländewagen", "cars", "top_speed", 210, "210 km/h", "Begrenzter Luxus-Offroader")
        add("VW ID.3 Pro", "Elektroauto", "cars", "top_speed", 160, "160 km/h", "Elektrischer Kompaktwagen")
        add("Smart #1", "Elektroauto", "cars", "top_speed", 180, "180 km/h", "Elektrischer Crossover")
        add("Fiat 500 Hybrid", "Kleinwagen", "cars", "top_speed", 167, "167 km/h", "Stadtwagen mit Mildhybrid")

        // ============================================================
        // CARS — Verbrauch (Liter/100 km, Wert in Zehnteln; bei E-Autos kWh/100 km)
        // ============================================================
        add("Mercedes-Benz G 500", "Geländewagen", "cars", "consumption", 121, "12,1 l/100 km", "Durstiger V8 im Luxus-Offroader")
        add("Porsche 911 Turbo S", "Sportwagen", "cars", "consumption", 121, "12,1 l/100 km", "Boxer-Biturbo unter Last")
        add("Audi RS 6 Avant", "Sportkombi", "cars", "consumption", 113, "11,3 l/100 km", "V8-Biturbo im Alltag")
        add("BMW M3 Touring", "Sportkombi", "cars", "consumption", 102, "10,2 l/100 km", "S58-Reihensechser")
        add("Porsche 911 Carrera", "Sportwagen", "cars", "consumption", 99, "9,9 l/100 km", "Klassischer Boxer-Sechszylinder")
        add("Mercedes-AMG A 45 S", "Kompaktsportler", "cars", "consumption", 88, "8,8 l/100 km", "Vierzylinder mit hoher Leistungsdichte")
        add("VW Touareg V6 TDI", "SUV", "cars", "consumption", 79, "7,9 l/100 km", "Diesel-V6 mit Allrad")
        add("BMW X5 xDrive30d", "SUV", "cars", "consumption", 70, "7,0 l/100 km", "Diesel-Sechszylinder")
        add("VW Tiguan 2.0 TDI", "SUV", "cars", "consumption", 60, "6,0 l/100 km", "Diesel-SUV für die Familie")
        add("Audi Q5 TDI", "SUV", "cars", "consumption", 60, "6,0 l/100 km", "Diesel-Mittelklasse-SUV")
        add("Ford Focus 1.0 EcoBoost", "Kompaktwagen", "cars", "consumption", 55, "5,5 l/100 km", "Dreizylinder-Turbobenziner")
        add("VW Golf 1.5 TSI", "Kompaktwagen", "cars", "consumption", 55, "5,5 l/100 km", "Effizienter Vierzylinder")
        add("Opel Corsa 1.2", "Kleinwagen", "cars", "consumption", 52, "5,2 l/100 km", "Dreizylinder-Benziner")
        add("Audi A1 25 TFSI", "Kleinwagen", "cars", "consumption", 51, "5,1 l/100 km", "Sparsamer Dreizylinder")
        add("VW Polo TSI", "Kleinwagen", "cars", "consumption", 50, "5,0 l/100 km", "Effizienter Kleinwagen")
        add("VW Passat 2.0 TDI", "Kombi", "cars", "consumption", 50, "5,0 l/100 km", "Bewährter Diesel-Vierzylinder")
        add("BMW 320d", "Limousine", "cars", "consumption", 47, "4,7 l/100 km", "Klassiker für Vielfahrer")
        add("Mercedes A 180 d", "Kompaktwagen", "cars", "consumption", 47, "4,7 l/100 km", "Diesel-Kompaktwagen")
        add("Skoda Octavia 2.0 TDI", "Kombi", "cars", "consumption", 44, "4,4 l/100 km", "Sparsamer Familienkombi")
        add("Toyota Yaris Hybrid", "Kleinwagen", "cars", "consumption", 41, "4,1 l/100 km", "Vollhybrid-Kleinwagen")

        // ============================================================
        // CARS — Produktionszahlen (Einheiten pro Jahr, weltweit)
        // ============================================================
        add("VW Tiguan", "SUV", "cars", "production", 430_000, "430.000 Stück", "Bestseller-SUV von VW")
        add("BMW 3er", "Limousine", "cars", "production", 390_000, "390.000 Stück", "Erfolgsmodell der Businessklasse")
        add("Mercedes GLC", "SUV", "cars", "production", 340_000, "340.000 Stück", "Bestseller-SUV von Mercedes")
        add("Mercedes C-Klasse", "Limousine", "cars", "production", 300_000, "300.000 Stück", "Premium-Mittelklasse-Bestseller")
        add("Audi Q5", "SUV", "cars", "production", 290_000, "290.000 Stück", "Globaler SUV-Erfolg")
        add("Skoda Octavia", "Kombi", "cars", "production", 280_000, "280.000 Stück", "Skoda-Bestseller")
        add("VW T-Roc", "SUV", "cars", "production", 280_000, "280.000 Stück", "Kompakt-SUV von VW")
        add("BMW X3", "SUV", "cars", "production", 250_000, "250.000 Stück", "Mittelklasse-SUV mit Tradition")
        add("VW Golf", "Kompaktwagen", "cars", "production", 250_000, "250.000 Stück", "Generation 8")
        add("BMW X1", "SUV", "cars", "production", 220_000, "220.000 Stück", "Einstiegs-SUV von BMW")
        add("Audi A3", "Kompaktwagen", "cars", "production", 200_000, "200.000 Stück", "Premium-Kompaktwagen")
        add("Mercedes E-Klasse", "Limousine", "cars", "production", 150_000, "150.000 Stück", "Klassische Businessklasse")
        add("VW Polo", "Kleinwagen", "cars", "production", 150_000, "150.000 Stück", "Kleinwagen-Bestseller")
        add("Audi A4", "Limousine", "cars", "production", 140_000, "140.000 Stück", "Mittelklasse aus Ingolstadt")
        add("Opel Corsa", "Kleinwagen", "cars", "production", 140_000, "140.000 Stück", "Rüsselsheimer Kleinwagen")
        add("Porsche Cayenne", "SUV", "cars", "production", 95_000, "95.000 Stück", "Erfolgreichster Porsche")
        add("VW Passat", "Kombi", "cars", "production", 80_000, "80.000 Stück", "Klassische Businessklasse")
        add("Opel Astra", "Kompaktwagen", "cars", "production", 70_000, "70.000 Stück", "Rüsselsheimer Volumenmodell")
        add("Ford Focus", "Kompaktwagen", "cars", "production", 60_000, "60.000 Stück", "Saarlouis-Produktion")
        add("Porsche 911", "Sportwagen", "cars", "production", 40_000, "40.000 Stück", "Sportwagen-Ikone in Zuffenhausen")

        // ============================================================
        // DAILY LIFE — Dönerpreise (Cent, displayValue zeigt Euro)
        // ============================================================
        add("München", "Dönerpreis", "daily_life", "doner_prices", 800, "8,00 €", "Bayerische Metropole, höchste Preise")
        add("Frankfurt am Main", "Dönerpreis", "daily_life", "doner_prices", 750, "7,50 €", "Bankenmetropole, hohes Preisniveau")
        add("Stuttgart", "Dönerpreis", "daily_life", "doner_prices", 750, "7,50 €", "Hochpreisige Schwabenmetropole")
        add("Hamburg", "Dönerpreis", "daily_life", "doner_prices", 720, "7,20 €", "Hansestadt im oberen Preissegment")
        add("Düsseldorf", "Dönerpreis", "daily_life", "doner_prices", 720, "7,20 €", "Hochpreisige Rheinmetropole")
        add("Berlin", "Dönerpreis", "daily_life", "doner_prices", 700, "7,00 €", "Hauptstadt der Dönerszene")
        add("Köln", "Dönerpreis", "daily_life", "doner_prices", 680, "6,80 €", "Domstadt mit moderaten Preisen")
        add("Nürnberg", "Dönerpreis", "daily_life", "doner_prices", 650, "6,50 €", "Frankenmetropole")
        add("Bremen", "Dönerpreis", "daily_life", "doner_prices", 650, "6,50 €", "Hansestadt mit fairen Preisen")
        add("Mainz", "Dönerpreis", "daily_life", "doner_prices", 650, "6,50 €", "Karnevalsstadt am Rhein")
        add("Hannover", "Dönerpreis", "daily_life", "doner_prices", 620, "6,20 €", "Niedersachsens Hauptstadt")
        add("Saarbrücken", "Dönerpreis", "daily_life", "doner_prices", 600, "6,00 €", "Saar-Metropole")
        add("Leipzig", "Dönerpreis", "daily_life", "doner_prices", 600, "6,00 €", "Messestadt mit moderaten Preisen")
        add("Mannheim", "Dönerpreis", "daily_life", "doner_prices", 600, "6,00 €", "Quadratestadt am Rhein")
        add("Dortmund", "Dönerpreis", "daily_life", "doner_prices", 580, "5,80 €", "Ruhrgebiet, faire Preise")
        add("Dresden", "Dönerpreis", "daily_life", "doner_prices", 580, "5,80 €", "Sachsenmetropole")
        add("Essen", "Dönerpreis", "daily_life", "doner_prices", 550, "5,50 €", "Zentrum des Ruhrgebiets")
        add("Bochum", "Dönerpreis", "daily_life", "doner_prices", 550, "5,50 €", "Günstige Ruhrpott-Preise")
        add("Wuppertal", "Dönerpreis", "daily_life", "doner_prices", 530, "5,30 €", "Bergische Metropole")
        add("Magdeburg", "Dönerpreis", "daily_life", "doner_prices", 500, "5,00 €", "Sehr günstig in Sachsen-Anhalt")

        // ============================================================
        // DAILY LIFE — Lebensmittelpreise (Cent, displayValue zeigt Euro)
        // ============================================================
        add("1 kg Rindersteak", "Supermarkt", "daily_life", "food_prices", 3_500, "35,00 €", "Premium-Rindfleisch")
        add("1 kg Lachsfilet", "Supermarkt", "daily_life", "food_prices", 2_900, "29,00 €", "Frischer Lachs")
        add("1 Liter Olivenöl", "Supermarkt", "daily_life", "food_prices", 1_200, "12,00 €", "Preise stark gestiegen")
        add("1 kg Hähnchenbrust", "Supermarkt", "daily_life", "food_prices", 1_100, "11,00 €", "Beliebtes Mager-Eiweiß")
        add("500 g Hackfleisch", "Supermarkt", "daily_life", "food_prices", 550, "5,50 €", "Gemischtes Hack")
        add("1 kg Bananen", "Supermarkt", "daily_life", "food_prices", 220, "2,20 €", "Importfrucht-Klassiker")
        add("1 kg Äpfel", "Supermarkt", "daily_life", "food_prices", 280, "2,80 €", "Deutsche Frucht im Sortiment")
        add("500 g Tomaten", "Supermarkt", "daily_life", "food_prices", 250, "2,50 €", "Importware und Hollandware")
        add("1 kg Kartoffeln", "Supermarkt", "daily_life", "food_prices", 180, "1,80 €", "Heißgeliebtes Grundnahrungsmittel")
        add("1 kg Brot", "Supermarkt", "daily_life", "food_prices", 320, "3,20 €", "Mischbrot vom Bäcker")
        add("250 g Butter", "Supermarkt", "daily_life", "food_prices", 240, "2,40 €", "Markenbutter")
        add("250 g Camembert", "Supermarkt", "daily_life", "food_prices", 230, "2,30 €", "Klassiker im Kühlregal")
        add("10 Eier", "Supermarkt", "daily_life", "food_prices", 290, "2,90 €", "Eier Größe M")
        add("1 Tafel Schokolade", "Supermarkt", "daily_life", "food_prices", 250, "2,50 €", "Markenschokolade 100 g")
        add("1 Liter Apfelsaft", "Supermarkt", "daily_life", "food_prices", 180, "1,80 €", "Direktsaft")
        add("1 Liter Vollmilch", "Supermarkt", "daily_life", "food_prices", 110, "1,10 €", "3,5 % Fett")
        add("1 kg Mehl", "Supermarkt", "daily_life", "food_prices", 130, "1,30 €", "Weizenmehl Type 405")
        add("500 g Spaghetti", "Supermarkt", "daily_life", "food_prices", 150, "1,50 €", "Italienische Pasta")
        add("Tiefkühlpizza 350 g", "Supermarkt", "daily_life", "food_prices", 250, "2,50 €", "Markenpizza")
        add("0,5 l Dose Bier", "Supermarkt", "daily_life", "food_prices", 90, "0,90 €", "Pils im Supermarkt")

        // ============================================================
        // DAILY LIFE — Stromkosten (ct/kWh)
        // ============================================================
        add("München (Stadtwerke)", "Versorger", "daily_life", "electricity_costs", 44, "44 ct/kWh", "Bayerische Landeshauptstadt")
        add("Bayern", "Durchschnitt", "daily_life", "electricity_costs", 42, "42 ct/kWh", "Höchste Strompreise im Bundesland")
        add("Baden-Württemberg", "Durchschnitt", "daily_life", "electricity_costs", 41, "41 ct/kWh", "Industriereiches Bundesland")
        add("E.ON Grundversorgung", "Versorger", "daily_life", "electricity_costs", 41, "41 ct/kWh", "Bundesweiter Grundversorger")
        add("Hessen", "Durchschnitt", "daily_life", "electricity_costs", 40, "40 ct/kWh", "Frankfurter Region")
        add("Nordrhein-Westfalen", "Durchschnitt", "daily_life", "electricity_costs", 39, "39 ct/kWh", "Industriestandort NRW")
        add("Hamburg", "Durchschnitt", "daily_life", "electricity_costs", 38, "38 ct/kWh", "Hansestadt im Norden")
        add("Saarland", "Durchschnitt", "daily_life", "electricity_costs", 38, "38 ct/kWh", "Saar-Region")
        add("Berlin", "Durchschnitt", "daily_life", "electricity_costs", 37, "37 ct/kWh", "Hauptstadtdurchschnitt")
        add("Niedersachsen", "Durchschnitt", "daily_life", "electricity_costs", 37, "37 ct/kWh", "Energieland Niedersachsen")
        add("Rheinland-Pfalz", "Durchschnitt", "daily_life", "electricity_costs", 37, "37 ct/kWh", "Weinland am Rhein")
        add("Bremen", "Durchschnitt", "daily_life", "electricity_costs", 36, "36 ct/kWh", "Hansestadt Bremen")
        add("Vattenfall Berlin", "Versorger", "daily_life", "electricity_costs", 36, "36 ct/kWh", "Großer Stromversorger")
        add("Sachsen", "Durchschnitt", "daily_life", "electricity_costs", 35, "35 ct/kWh", "Stromnetz im Osten")
        add("Brandenburg", "Durchschnitt", "daily_life", "electricity_costs", 35, "35 ct/kWh", "Windkraftland Brandenburg")
        add("Schleswig-Holstein", "Durchschnitt", "daily_life", "electricity_costs", 35, "35 ct/kWh", "Windreich an der Küste")
        add("Thüringen", "Durchschnitt", "daily_life", "electricity_costs", 34, "34 ct/kWh", "Grünes Herz Deutschlands")
        add("Mecklenburg-Vorpommern", "Durchschnitt", "daily_life", "electricity_costs", 34, "34 ct/kWh", "Ostsee-Küstenland")
        add("Sachsen-Anhalt", "Durchschnitt", "daily_life", "electricity_costs", 33, "33 ct/kWh", "Niedrige Strompreise im Osten")
        add("Octopus Energy", "Versorger", "daily_life", "electricity_costs", 32, "32 ct/kWh", "Günstiger Ökostromanbieter")

        // ============================================================
        // DAILY LIFE — Mietpreise (Warmmiete 3-Zimmer-Wohnung in €/Monat)
        // ============================================================
        add("München", "3-Zi-Warmmiete", "daily_life", "rent_prices", 2_200, "2.200 €", "Bayerische Landeshauptstadt")
        add("Frankfurt am Main", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_700, "1.700 €", "Finanzzentrum")
        add("Stuttgart", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_650, "1.650 €", "Schwabenmetropole")
        add("Berlin", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_600, "1.600 €", "Hauptstadt mit steigenden Mieten")
        add("Hamburg", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_550, "1.550 €", "Hansestadt")
        add("Wiesbaden", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_500, "1.500 €", "Landeshauptstadt Hessens")
        add("Düsseldorf", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_450, "1.450 €", "Rheinmetropole")
        add("Freiburg im Breisgau", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_450, "1.450 €", "Studierendenstadt")
        add("Heidelberg", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_450, "1.450 €", "Beliebte Universitätsstadt")
        add("Köln", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_400, "1.400 €", "Domstadt am Rhein")
        add("Bonn", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_350, "1.350 €", "Beethoven-Stadt")
        add("Mainz", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_300, "1.300 €", "BioNTech-Standort")
        add("Karlsruhe", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_250, "1.250 €", "Badische Fächerstadt")
        add("Nürnberg", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_200, "1.200 €", "Frankenmetropole")
        add("Hannover", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_100, "1.100 €", "Messestadt")
        add("Bremen", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_050, "1.050 €", "Hansestadt an der Weser")
        add("Dresden", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_000, "1.000 €", "Elbflorenz")
        add("Leipzig", "3-Zi-Warmmiete", "daily_life", "rent_prices", 1_000, "1.000 €", "Wachsende Messestadt")
        add("Dortmund", "3-Zi-Warmmiete", "daily_life", "rent_prices", 950, "950 €", "Ruhrgebietsmetropole")
        add("Essen", "3-Zi-Warmmiete", "daily_life", "rent_prices", 900, "900 €", "Zentrum des Ruhrgebiets")

        // ============================================================
        // DAILY LIFE — Spritpreise Super E10 (Cent pro Liter, displayValue zeigt Euro)
        // ============================================================
        add("Tankstelle Autobahn", "Autobahnraststation", "daily_life", "fuel_prices", 199, "1,99 €/l", "Teuerste Standorte in Deutschland")
        add("Baden-Württemberg", "Bundesland", "daily_life", "fuel_prices", 178, "1,78 €/l", "Südwesten meist etwas teurer")
        add("Hessen", "Bundesland", "daily_life", "fuel_prices", 177, "1,77 €/l", "Frankfurter Region")
        add("Rheinland-Pfalz", "Bundesland", "daily_life", "fuel_prices", 176, "1,76 €/l", "Weinland")
        add("Nordrhein-Westfalen", "Bundesland", "daily_life", "fuel_prices", 176, "1,76 €/l", "Bevölkerungsreichstes Land")
        add("Berlin", "Stadtstaat", "daily_life", "fuel_prices", 175, "1,75 €/l", "Hauptstadtschnitt")
        add("Bayern", "Bundesland", "daily_life", "fuel_prices", 175, "1,75 €/l", "Freistaat")
        add("Saarland", "Bundesland", "daily_life", "fuel_prices", 175, "1,75 €/l", "Saar-Region")
        add("Niedersachsen", "Bundesland", "daily_life", "fuel_prices", 174, "1,74 €/l", "Norddeutschland")
        add("Hamburg", "Stadtstaat", "daily_life", "fuel_prices", 174, "1,74 €/l", "Hansestadt")
        add("Brandenburg", "Bundesland", "daily_life", "fuel_prices", 174, "1,74 €/l", "Umland von Berlin")
        add("Schleswig-Holstein", "Bundesland", "daily_life", "fuel_prices", 174, "1,74 €/l", "Land zwischen den Meeren")
        add("Thüringen", "Bundesland", "daily_life", "fuel_prices", 174, "1,74 €/l", "Mitteldeutschland")
        add("Bremen", "Stadtstaat", "daily_life", "fuel_prices", 173, "1,73 €/l", "Hansestadt an der Weser")
        add("Sachsen", "Bundesland", "daily_life", "fuel_prices", 173, "1,73 €/l", "Freistaat im Osten")
        add("Mecklenburg-Vorpommern", "Bundesland", "daily_life", "fuel_prices", 173, "1,73 €/l", "Ostsee-Küstenland")
        add("Sachsen-Anhalt", "Bundesland", "daily_life", "fuel_prices", 173, "1,73 €/l", "Günstige Spritpreise im Osten")
        add("Österreich Grenze", "Tankstelle", "daily_life", "fuel_prices", 165, "1,65 €/l", "Günstig im Nachbarland")
        add("Tschechien Grenze", "Tankstelle", "daily_life", "fuel_prices", 158, "1,58 €/l", "Beliebter Tanktourismus")
        add("Polen Grenze", "Tankstelle", "daily_life", "fuel_prices", 145, "1,45 €/l", "Deutlich günstigeres Benzin")

        // ============================================================
        // COMPANIES — Mitarbeitende
        // ============================================================
        add("Volkswagen Group", "Wolfsburg", "companies", "employees", 684_000, "684.000 Mitarbeitende", "Einer der größten Autobauer der Welt")
        add("Deutsche Post DHL", "Bonn", "companies", "employees", 594_000, "594.000 Mitarbeitende", "Globaler Logistikkonzern")
        add("Bosch", "Gerlingen", "companies", "employees", 429_000, "429.000 Mitarbeitende", "Technologie- und Industriekonzern")
        add("Siemens", "München", "companies", "employees", 320_000, "320.000 Mitarbeitende", "Industrie- und Technologiekonzern")
        add("Deutsche Telekom", "Bonn", "companies", "employees", 199_000, "199.000 Mitarbeitende", "Telekommunikationskonzern")
        add("Mercedes-Benz Group", "Stuttgart", "companies", "employees", 166_000, "166.000 Mitarbeitende", "Premium-Automobilhersteller")
        add("Allianz", "München", "companies", "employees", 157_000, "157.000 Mitarbeitende", "Großer Versicherungskonzern")
        add("BMW Group", "München", "companies", "employees", 155_000, "155.000 Mitarbeitende", "Automobilkonzern aus Bayern")
        add("BASF", "Ludwigshafen", "companies", "employees", 112_000, "112.000 Mitarbeitende", "Chemiekonzern")
        add("SAP", "Walldorf", "companies", "employees", 108_000, "108.000 Mitarbeitende", "Softwarekonzern")
        add("Schwarz Gruppe", "Neckarsulm", "companies", "employees", 575_000, "575.000 Mitarbeitende", "Konzernmutter von Lidl und Kaufland")
        add("Edeka-Verbund", "Hamburg", "companies", "employees", 410_000, "410.000 Mitarbeitende", "Größter Lebensmittelhändler Deutschlands")
        add("REWE Group", "Köln", "companies", "employees", 360_000, "360.000 Mitarbeitende", "Handelskonzern mit Vielmarkenstrategie")
        add("Deutsche Bahn", "Berlin", "companies", "employees", 330_000, "330.000 Mitarbeitende", "Bundeseigener Logistikkonzern")
        add("Continental", "Hannover", "companies", "employees", 190_000, "190.000 Mitarbeitende", "Reifen- und Automotive-Zulieferer")
        add("Fresenius", "Bad Homburg", "companies", "employees", 190_000, "190.000 Mitarbeitende", "Gesundheitskonzern")
        add("ZF Friedrichshafen", "Friedrichshafen", "companies", "employees", 165_000, "165.000 Mitarbeitende", "Antriebs- und Fahrwerkstechnik")
        add("ThyssenKrupp", "Essen", "companies", "employees", 98_000, "98.000 Mitarbeitende", "Industriekonzern aus dem Ruhrgebiet")
        add("Metro AG", "Düsseldorf", "companies", "employees", 93_000, "93.000 Mitarbeitende", "Großhandelskonzern")
        add("Aldi Süd", "Mülheim an der Ruhr", "companies", "employees", 75_000, "75.000 Mitarbeitende", "Discounter mit globalem Auftritt")
        add("Bayer", "Leverkusen", "companies", "employees", 100_000, "100.000 Mitarbeitende", "Pharma- und Agrarkonzern")
        add("E.ON", "Essen", "companies", "employees", 72_000, "72.000 Mitarbeitende", "Energiekonzern")
        add("RWE", "Essen", "companies", "employees", 21_000, "21.000 Mitarbeitende", "Strom- und Energieerzeuger")
        add("Adidas", "Herzogenaurach", "companies", "employees", 62_000, "62.000 Mitarbeitende", "Sportartikelhersteller")
        add("Henkel", "Düsseldorf", "companies", "employees", 47_000, "47.000 Mitarbeitende", "Konsumgüter- und Klebstoffkonzern")
        add("Porsche AG", "Stuttgart", "companies", "employees", 42_000, "42.000 Mitarbeitende", "Sportwagenhersteller")
        add("Lufthansa", "Köln", "companies", "employees", 105_000, "105.000 Mitarbeitende", "Größte deutsche Fluggesellschaft")
        add("Münchener Rück", "München", "companies", "employees", 43_000, "43.000 Mitarbeitende", "Rückversicherungskonzern")

        // ============================================================
        // COMPANIES — Umsatz (Jahresumsatz in Mio. €)
        // ============================================================
        add("Volkswagen Group", "Wolfsburg", "companies", "revenue", 322_000, "322 Mrd. €", "Umsatzstärkster deutscher Konzern")
        add("Schwarz Gruppe", "Neckarsulm", "companies", "revenue", 167_000, "167 Mrd. €", "Konzernmutter von Lidl und Kaufland")
        add("Allianz", "München", "companies", "revenue", 161_700, "161,7 Mrd. €", "Versicherungskonzern")
        add("BMW Group", "München", "companies", "revenue", 155_000, "155 Mrd. €", "Automobilkonzern aus Bayern")
        add("Mercedes-Benz Group", "Stuttgart", "companies", "revenue", 153_000, "153 Mrd. €", "Premium-Automobilhersteller")
        add("Deutsche Telekom", "Bonn", "companies", "revenue", 115_800, "115,8 Mrd. €", "Telekommunikationskonzern")
        add("E.ON", "Essen", "companies", "revenue", 94_300, "94,3 Mrd. €", "Energieversorger")
        add("REWE Group", "Köln", "companies", "revenue", 92_300, "92,3 Mrd. €", "Handelskonzern")
        add("Bosch", "Gerlingen", "companies", "revenue", 91_500, "91,5 Mrd. €", "Industrie- und Technologiekonzern")
        add("Deutsche Post DHL", "Bonn", "companies", "revenue", 81_800, "81,8 Mrd. €", "Globaler Logistikkonzern")
        add("Siemens", "München", "companies", "revenue", 77_800, "77,8 Mrd. €", "Industrie- und Technologiekonzern")
        add("Edeka-Verbund", "Hamburg", "companies", "revenue", 75_000, "75 Mrd. €", "Lebensmitteleinzelhandel")
        add("BASF", "Ludwigshafen", "companies", "revenue", 68_900, "68,9 Mrd. €", "Größter Chemiekonzern der Welt")
        add("Bayer", "Leverkusen", "companies", "revenue", 47_600, "47,6 Mrd. €", "Pharma- und Agrarkonzern")
        add("Continental", "Hannover", "companies", "revenue", 41_000, "41 Mrd. €", "Automotive-Zulieferer")
        add("ThyssenKrupp", "Essen", "companies", "revenue", 37_500, "37,5 Mrd. €", "Industriekonzern")
        add("Lufthansa", "Köln", "companies", "revenue", 35_400, "35,4 Mrd. €", "Airline-Konzern")
        add("SAP", "Walldorf", "companies", "revenue", 33_500, "33,5 Mrd. €", "Softwarekonzern")
        add("RWE", "Essen", "companies", "revenue", 26_000, "26 Mrd. €", "Strom- und Energieerzeuger")
        add("Henkel", "Düsseldorf", "companies", "revenue", 21_500, "21,5 Mrd. €", "Konsumgüter- und Klebstoffkonzern")

        // ============================================================
        // COMPANIES — Marktwert (Börsenwert in Mrd. €)
        // ============================================================
        add("SAP", "Walldorf", "companies", "market_value", 290_000, "290 Mrd. €", "Wertvollstes DAX-Unternehmen")
        add("Linde plc", "Döllwang/USA", "companies", "market_value", 210_000, "210 Mrd. €", "Gase-Konzern, jetzt US-gelistet")
        add("Siemens", "München", "companies", "market_value", 165_000, "165 Mrd. €", "Industrie- und Technologiekonzern")
        add("Deutsche Telekom", "Bonn", "companies", "market_value", 140_000, "140 Mrd. €", "DAX-Schwergewicht")
        add("Airbus", "Toulouse/Hamburg", "companies", "market_value", 120_000, "120 Mrd. €", "Flugzeughersteller")
        add("Allianz", "München", "companies", "market_value", 115_000, "115 Mrd. €", "Versicherungskonzern")
        add("Porsche AG", "Stuttgart", "companies", "market_value", 70_000, "70 Mrd. €", "Sportwagen-IPO 2022")
        add("Mercedes-Benz Group", "Stuttgart", "companies", "market_value", 65_000, "65 Mrd. €", "Premium-Automobilhersteller")
        add("Münchener Rück", "München", "companies", "market_value", 62_000, "62 Mrd. €", "Welt-Rückversicherer")
        add("BMW Group", "München", "companies", "market_value", 55_000, "55 Mrd. €", "Automobilkonzern aus Bayern")
        add("Volkswagen Group", "Wolfsburg", "companies", "market_value", 50_000, "50 Mrd. €", "DAX-Konzern, Vorzugsaktien")
        add("DHL Group", "Bonn", "companies", "market_value", 50_000, "50 Mrd. €", "Globaler Logistikkonzern")
        add("Infineon", "München", "companies", "market_value", 46_000, "46 Mrd. €", "Halbleiterhersteller")
        add("BASF", "Ludwigshafen", "companies", "market_value", 40_000, "40 Mrd. €", "Chemiekonzern")
        add("Adidas", "Herzogenaurach", "companies", "market_value", 38_000, "38 Mrd. €", "Sportartikelhersteller")
        add("Deutsche Börse", "Frankfurt am Main", "companies", "market_value", 36_000, "36 Mrd. €", "Betreiber des Xetra-Handels")
        add("Henkel", "Düsseldorf", "companies", "market_value", 32_000, "32 Mrd. €", "Konsumgüter- und Klebstoffkonzern")
        add("Beiersdorf", "Hamburg", "companies", "market_value", 30_000, "30 Mrd. €", "Nivea-Konzern")
        add("Bayer", "Leverkusen", "companies", "market_value", 25_000, "25 Mrd. €", "Pharma- und Agrarkonzern")
        add("Heidelberg Materials", "Heidelberg", "companies", "market_value", 17_000, "17 Mrd. €", "Baustoffkonzern")

        // ============================================================
        // COMPANIES — Gründungsjahr
        // ============================================================
        add("Hofbräu München", "Brauerei", "companies", "founding_year", 1589, "1589", "Eine der ältesten deutschen Marken")
        add("Opel", "Rüsselsheim", "companies", "founding_year", 1862, "1862", "Ursprünglich Nähmaschinenfabrik")
        add("Bayer", "Leverkusen", "companies", "founding_year", 1863, "1863", "Pharma- und Chemiekonzern")
        add("BASF", "Ludwigshafen", "companies", "founding_year", 1865, "1865", "Badische Anilin- und Sodafabrik")
        add("Deutsche Bank", "Frankfurt am Main", "companies", "founding_year", 1870, "1870", "Gegründet zur Förderung des Außenhandels")
        add("Continental", "Hannover", "companies", "founding_year", 1871, "1871", "Gummiwarenfabrik")
        add("Beck's Brauerei", "Bremen", "companies", "founding_year", 1873, "1873", "Weltweit verkaufter Norddeutscher")
        add("Henkel", "Düsseldorf", "companies", "founding_year", 1876, "1876", "Persil-Marke seit 1907")
        add("Bosch", "Gerlingen", "companies", "founding_year", 1886, "1886", "Werkstatt für Feinmechanik")
        add("Allianz", "München", "companies", "founding_year", 1890, "1890", "Versicherungskonzern")
        add("Siemens", "Berlin/München", "companies", "founding_year", 1847, "1847", "Telegraphen-Bauanstalt")
        add("Audi", "Ingolstadt", "companies", "founding_year", 1909, "1909", "August Horch gründet 'Audi'")
        add("BMW", "München", "companies", "founding_year", 1916, "1916", "Bayerische Flugzeugwerke")
        add("Mercedes-Benz", "Stuttgart", "companies", "founding_year", 1926, "1926", "Fusion von Daimler und Benz")
        add("REWE", "Köln", "companies", "founding_year", 1927, "1927", "Genossenschaftshandel")
        add("Porsche", "Stuttgart", "companies", "founding_year", 1931, "1931", "Konstruktionsbüro Porsche")
        add("Lidl", "Neckarsulm", "companies", "founding_year", 1932, "1932", "Ursprünglich Obstgroßhandel")
        add("Volkswagen", "Wolfsburg", "companies", "founding_year", 1937, "1937", "Gegründet für den 'KdF-Wagen'")
        add("Aldi", "Essen/Mülheim", "companies", "founding_year", 1946, "1946", "Brüder Albrecht")
        add("Puma", "Herzogenaurach", "companies", "founding_year", 1948, "1948", "Rudolf Dassler gründet Puma")
        add("Adidas", "Herzogenaurach", "companies", "founding_year", 1949, "1949", "Adolf Dassler gründet Adidas")
        add("Lufthansa", "Köln", "companies", "founding_year", 1953, "1953", "Nachfolgerin der Deutsche Luft Hansa")
        add("SAP", "Walldorf", "companies", "founding_year", 1972, "1972", "Fünf Ex-IBM-Mitarbeiter")
        add("Deutsche Telekom", "Bonn", "companies", "founding_year", 1995, "1995", "Privatisierung der Deutschen Bundespost")

        // ============================================================
        // SOCIAL MEDIA — Instagram-Follower (deutsche Accounts/Marken)
        // ============================================================
        add("FC Bayern München", "Fußballclub", "social_media", "instagram_followers", 42_000_000, "42 Mio. Follower", "International sehr sichtbarer Club")
        add("Mercedes-AMG", "Automarke", "social_media", "instagram_followers", 17_000_000, "17 Mio. Follower", "Performance-Marke mit starker Bildsprache")
        add("BMW", "Automarke", "social_media", "instagram_followers", 39_000_000, "39 Mio. Follower", "Globale Automobilmarke")
        add("Porsche", "Automarke", "social_media", "instagram_followers", 31_000_000, "31 Mio. Follower", "Sportwagen aus Stuttgart")
        add("Borussia Dortmund", "Fußballclub", "social_media", "instagram_followers", 21_000_000, "21 Mio. Follower", "Große internationale Fanbase")
        add("Pamela Reif", "Creatorin", "social_media", "instagram_followers", 9_200_000, "9,2 Mio. Follower", "Fitness- und Lifestyle-Content")
        add("Toni Kroos", "Fußballer", "social_media", "instagram_followers", 49_000_000, "49 Mio. Follower", "Weltmeister und Champions-League-Sieger")
        add("Dirk Nowitzki", "Basketball-Legende", "social_media", "instagram_followers", 2_200_000, "2,2 Mio. Follower", "NBA-Legende aus Würzburg")
        add("Julian Draxler", "Fußballer", "social_media", "instagram_followers", 5_000_000, "5 Mio. Follower", "Deutscher Nationalspieler")
        add("DAZN DACH", "Sportplattform", "social_media", "instagram_followers", 1_900_000, "1,9 Mio. Follower", "Sport-Content im deutschsprachigen Raum")
        add("Mesut Özil", "Ex-Nationalspieler", "social_media", "instagram_followers", 22_000_000, "22 Mio. Follower", "Weltmeister 2014")
        add("Manuel Neuer", "Torwart", "social_media", "instagram_followers", 11_000_000, "11 Mio. Follower", "Kapitän der Nationalmannschaft")
        add("Heidi Klum", "Model & TV-Star", "social_media", "instagram_followers", 12_000_000, "12 Mio. Follower", "Germany's Next Topmodel")
        add("Marco Reus", "Fußballer", "social_media", "instagram_followers", 9_000_000, "9 Mio. Follower", "BVB- und Nationalspieler")
        add("Mats Hummels", "Fußballer", "social_media", "instagram_followers", 8_000_000, "8 Mio. Follower", "Weltmeister von 2014")
        add("Bibi Claeßen", "Influencerin", "social_media", "instagram_followers", 8_000_000, "8 Mio. Follower", "Lifestyle und Familie")
        add("Stefanie Giesinger", "Model", "social_media", "instagram_followers", 4_700_000, "4,7 Mio. Follower", "Fashion- und Lifestyle-Inhalte")
        add("Lena Meyer-Landrut", "Sängerin", "social_media", "instagram_followers", 4_200_000, "4,2 Mio. Follower", "ESC-Gewinnerin 2010")
        add("Joko Winterscheidt", "TV-Star", "social_media", "instagram_followers", 1_500_000, "1,5 Mio. Follower", "Moderator von 'wer stiehlt mir die Show'")

        // ============================================================
        // SOCIAL MEDIA — TikTok-Follower (deutsche Accounts)
        // ============================================================
        add("Younes Zarou", "Creator", "social_media", "tiktok_followers", 64_000_000, "64 Mio. Follower", "Erfolgreichster deutscher TikToker")
        add("Lisa und Lena", "Zwillinge", "social_media", "tiktok_followers", 30_000_000, "30 Mio. Follower", "Pionierinnen auf musical.ly")
        add("Noel Robinson", "Tanz-Creator", "social_media", "tiktok_followers", 30_000_000, "30 Mio. Follower", "Bekannt durch virale Tanzvideos")
        add("Falco Punch", "Magier", "social_media", "tiktok_followers", 18_000_000, "18 Mio. Follower", "Zauberei und Illusionen")
        add("Twenty4tim", "Creator", "social_media", "tiktok_followers", 9_500_000, "9,5 Mio. Follower", "Lifestyle- und Showcontent")
        add("Pamela Reif", "Fitness-Creatorin", "social_media", "tiktok_followers", 9_000_000, "9 Mio. Follower", "Trainingsvideos")
        add("BibisBeautyPalace", "Creatorin", "social_media", "tiktok_followers", 6_000_000, "6 Mio. Follower", "Aus YouTube zu TikTok gewechselt")
        add("Bekir Ekici", "Comedy-Creator", "social_media", "tiktok_followers", 5_000_000, "5 Mio. Follower", "Comedy- und Skit-Videos")
        add("Inscope21", "Creator", "social_media", "tiktok_followers", 5_000_000, "5 Mio. Follower", "Lifestyle und Fitness")
        add("KsFreak", "Creator", "social_media", "tiktok_followers", 4_500_000, "4,5 Mio. Follower", "YouTube- und TikTok-Star")
        add("Trymacs", "Streamer", "social_media", "tiktok_followers", 4_000_000, "4 Mio. Follower", "Twitch- und Gaming-Star")
        add("HeyMoritz", "Creator", "social_media", "tiktok_followers", 3_500_000, "3,5 Mio. Follower", "Travel- und Vlog-Content")
        add("Eljano2", "Comedy-Creator", "social_media", "tiktok_followers", 3_000_000, "3 Mio. Follower", "Skits und Sketche")
        add("Reezy", "Rapper", "social_media", "tiktok_followers", 2_800_000, "2,8 Mio. Follower", "Musik-Content auf TikTok")
        add("Patrice Aminati", "Creatorin", "social_media", "tiktok_followers", 2_500_000, "2,5 Mio. Follower", "Lifestyle und Familie")
        add("Younes Jones", "Creator", "social_media", "tiktok_followers", 1_500_000, "1,5 Mio. Follower", "Comedy- und Reactvideos")
        add("MontanaBlack", "Streamer", "social_media", "tiktok_followers", 1_200_000, "1,2 Mio. Follower", "Twitch-Star auf TikTok")
        add("Knossi", "Streamer", "social_media", "tiktok_followers", 1_000_000, "1 Mio. Follower", "Der König der Löwen")
        add("Tanzverbot", "Streamer", "social_media", "tiktok_followers", 950_000, "950 Tsd. Follower", "Streaming-Persönlichkeit")
        add("Lara Loft", "Streamerin", "social_media", "tiktok_followers", 800_000, "800 Tsd. Follower", "Gaming-Content")

        // ============================================================
        // SOCIAL MEDIA — YouTube-Abonnenten (deutsche Kanäle)
        // ============================================================
        add("Freekickerz", "Fußball-Kanal", "social_media", "youtube_subscribers", 9_500_000, "9,5 Mio. Abos", "Fußball-Challenges aus München")
        add("Julien Bam", "Entertainer", "social_media", "youtube_subscribers", 6_000_000, "6 Mio. Abos", "Musikparodien und Skits")
        add("Unge", "Vlogger", "social_media", "youtube_subscribers", 6_000_000, "6 Mio. Abos", "Vlogs aus aller Welt")
        add("BibisBeautyPalace", "Creatorin", "social_media", "youtube_subscribers", 5_600_000, "5,6 Mio. Abos", "Beauty und Lifestyle")
        add("Gronkh", "Gaming", "social_media", "youtube_subscribers", 5_000_000, "5 Mio. Abos", "Let's Play seit 2010")
        add("Paluten", "Gaming", "social_media", "youtube_subscribers", 4_800_000, "4,8 Mio. Abos", "Minecraft- und Familien-Content")
        add("Y-Titty", "Comedy", "social_media", "youtube_subscribers", 4_500_000, "4,5 Mio. Abos", "Klassiker der YouTube-Szene")
        add("ApeCrime", "Comedy", "social_media", "youtube_subscribers", 4_000_000, "4 Mio. Abos", "Sketchcomedy")
        add("Dagi Bee", "Creatorin", "social_media", "youtube_subscribers", 3_600_000, "3,6 Mio. Abos", "Beauty und Lifestyle")
        add("MontanaBlack88", "Streamer", "social_media", "youtube_subscribers", 3_500_000, "3,5 Mio. Abos", "Twitch-Highlights auf YouTube")
        add("Standart Skill", "Gaming", "social_media", "youtube_subscribers", 3_500_000, "3,5 Mio. Abos", "FIFA- und Gaming-Content")
        add("LeFloid", "Newschannel", "social_media", "youtube_subscribers", 3_200_000, "3,2 Mio. Abos", "News-Kommentar")
        add("Knossi", "Streamer", "social_media", "youtube_subscribers", 2_800_000, "2,8 Mio. Abos", "Streaming-König")
        add("Trymacs", "Streamer", "social_media", "youtube_subscribers", 2_500_000, "2,5 Mio. Abos", "Twitch- und FIFA-Star")
        add("Pietsmiet", "Gaming-Crew", "social_media", "youtube_subscribers", 2_500_000, "2,5 Mio. Abos", "Let's Play-Kollektiv")
        add("Concrafter Luca", "Gaming", "social_media", "youtube_subscribers", 2_500_000, "2,5 Mio. Abos", "Minecraft-Content")
        add("Rezo", "Politik & Comedy", "social_media", "youtube_subscribers", 2_000_000, "2 Mio. Abos", "Politische Videos und Comedy")
        add("HandOfBlood", "Gaming", "social_media", "youtube_subscribers", 1_800_000, "1,8 Mio. Abos", "League of Legends und mehr")
        add("Tomatolix", "Reportage", "social_media", "youtube_subscribers", 1_800_000, "1,8 Mio. Abos", "Selbstexperimente")
        add("Mr. Wissen2go", "Bildung", "social_media", "youtube_subscribers", 1_600_000, "1,6 Mio. Abos", "Wissens- und Nachrichten-Content")
        add("BastiGHG", "Gaming", "social_media", "youtube_subscribers", 1_500_000, "1,5 Mio. Abos", "Minecraft-Content")

        // ============================================================
        // SOCIAL MEDIA — Twitch-Follower (deutsche Streamer)
        // ============================================================
        add("MontanaBlack88", "Streamer", "social_media", "twitch_followers", 5_400_000, "5,4 Mio. Follower", "Buxtehude-Streamer")
        add("Trymacs", "Streamer", "social_media", "twitch_followers", 2_600_000, "2,6 Mio. Follower", "FIFA und Variety")
        add("Knossi", "Streamer", "social_media", "twitch_followers", 2_000_000, "2 Mio. Follower", "Der König der Löwen")
        add("Gronkh", "Streamer", "social_media", "twitch_followers", 1_700_000, "1,7 Mio. Follower", "Gaming-Veteran")
        add("Inscope21", "Streamer", "social_media", "twitch_followers", 1_600_000, "1,6 Mio. Follower", "Lifestyle und Gaming")
        add("ELoTRiX", "Streamer", "social_media", "twitch_followers", 1_400_000, "1,4 Mio. Follower", "FIFA- und Variety-Streamer")
        add("Standart Skill", "Streamer", "social_media", "twitch_followers", 1_300_000, "1,3 Mio. Follower", "FIFA- und Pack-Opening")
        add("Papaplatte", "Streamer", "social_media", "twitch_followers", 1_100_000, "1,1 Mio. Follower", "Variety-Streamer aus Berlin")
        add("BastiGHG", "Streamer", "social_media", "twitch_followers", 1_000_000, "1 Mio. Follower", "Gaming und IRL")
        add("Tanzverbot", "Streamer", "social_media", "twitch_followers", 950_000, "950 Tsd. Follower", "Streaming-Persönlichkeit")
        add("Sgt_Rumpel", "Streamerin", "social_media", "twitch_followers", 900_000, "900 Tsd. Follower", "Variety-Streaming")
        add("HandOfBlood", "Streamer", "social_media", "twitch_followers", 850_000, "850 Tsd. Follower", "League of Legends")
        add("Lara Loft", "Streamerin", "social_media", "twitch_followers", 800_000, "800 Tsd. Follower", "Gaming und IRL")
        add("Staiy", "Streamer", "social_media", "twitch_followers", 700_000, "700 Tsd. Follower", "Just Chatting und Variety")
        add("Tobinator", "Streamer", "social_media", "twitch_followers", 600_000, "600 Tsd. Follower", "Gaming- und Variety-Streamer")
        add("Rumathra", "Streamer", "social_media", "twitch_followers", 600_000, "600 Tsd. Follower", "Gaming und Reisen")
        add("Reved", "Streamerin", "social_media", "twitch_followers", 500_000, "500 Tsd. Follower", "Lifestyle- und Gaming-Streams")
        add("Pietsmiet", "Gaming-Crew", "social_media", "twitch_followers", 480_000, "480 Tsd. Follower", "Kollektiv-Streams")
        add("Naya Schmidt", "Streamerin", "social_media", "twitch_followers", 350_000, "350 Tsd. Follower", "Variety-Streamerin")
        add("AmarUlive", "Streamer", "social_media", "twitch_followers", 300_000, "300 Tsd. Follower", "FIFA und Variety")

        // ============================================================
        // GAMING — Verkaufszahlen (weltweit, lifetime)
        // ============================================================
        add("Minecraft", "Mojang, 2011", "gaming", "sales", 300_000_000, "300 Mio. Einheiten", "Meistverkauftes Spiel aller Zeiten")
        add("GTA V", "Rockstar, 2013", "gaming", "sales", 200_000_000, "200 Mio. Einheiten", "Lifetime über alle Plattformen")
        add("Tetris (EA Mobile)", "EA, 2006", "gaming", "sales", 100_000_000, "100 Mio. Einheiten", "Erfolgreichste Tetris-Version")
        add("Wii Sports", "Nintendo, 2006", "gaming", "sales", 83_000_000, "83 Mio. Einheiten", "Wurde der Wii beigelegt")
        add("PUBG: Battlegrounds", "Krafton, 2017", "gaming", "sales", 75_000_000, "75 Mio. Einheiten", "Battle-Royale-Pionier")
        add("Mario Kart 8 Deluxe", "Nintendo, 2017", "gaming", "sales", 67_000_000, "67 Mio. Einheiten", "Bestverkauftes Switch-Spiel")
        add("Red Dead Redemption 2", "Rockstar, 2018", "gaming", "sales", 65_000_000, "65 Mio. Einheiten", "Western-Open-World")
        add("The Elder Scrolls V: Skyrim", "Bethesda, 2011", "gaming", "sales", 60_000_000, "60 Mio. Einheiten", "Auch auf der Alexa erschienen")
        add("Super Mario Bros.", "Nintendo, 1985", "gaming", "sales", 58_000_000, "58 Mio. Einheiten", "Verkauft mit dem NES")
        add("The Witcher 3: Wild Hunt", "CD Projekt, 2015", "gaming", "sales", 50_000_000, "50 Mio. Einheiten", "Polnisches Meisterwerk")
        add("Overwatch", "Blizzard, 2016", "gaming", "sales", 50_000_000, "50 Mio. Einheiten", "Hero-Shooter-Hit")
        add("Animal Crossing: New Horizons", "Nintendo, 2020", "gaming", "sales", 45_000_000, "45 Mio. Einheiten", "Pandemie-Bestseller")
        add("Terraria", "Re-Logic, 2011", "gaming", "sales", 45_000_000, "45 Mio. Einheiten", "2D-Sandbox-Klassiker")
        add("Pokémon Rot/Blau", "Nintendo, 1996", "gaming", "sales", 31_000_000, "31 Mio. Einheiten", "Game Boy-Klassiker")
        add("Cyberpunk 2077", "CD Projekt, 2020", "gaming", "sales", 30_000_000, "30 Mio. Einheiten", "Holprig gestartet, gut gereift")
        add("Hogwarts Legacy", "Avalanche, 2023", "gaming", "sales", 30_000_000, "30 Mio. Einheiten", "Bestseller des Jahres 2023")
        add("Diablo III", "Blizzard, 2012", "gaming", "sales", 30_000_000, "30 Mio. Einheiten", "Action-Rollenspiel")
        add("CoD: Modern Warfare (2019)", "Activision, 2019", "gaming", "sales", 30_000_000, "30 Mio. Einheiten", "Reboot der Serie")
        add("Pokémon Sword & Shield", "Nintendo, 2019", "gaming", "sales", 26_000_000, "26 Mio. Einheiten", "Switch-Pokémon")
        add("Elden Ring", "FromSoftware, 2022", "gaming", "sales", 25_000_000, "25 Mio. Einheiten", "Game of the Year 2022")
        add("Baldur's Gate 3", "Larian, 2023", "gaming", "sales", 15_000_000, "15 Mio. Einheiten", "GOTY 2023")
        add("Helldivers 2", "Arrowhead, 2024", "gaming", "sales", 12_000_000, "12 Mio. Einheiten", "PlayStation Studios-Hit 2024")

        // ============================================================
        // GAMING — Spielerzahlen (Steam-Peak gleichzeitig)
        // ============================================================
        add("PUBG: Battlegrounds", "Steam-Peak", "gaming", "players", 3_257_000, "3,26 Mio. Spieler", "Rekord von 2018")
        add("Palworld", "Steam-Peak", "gaming", "players", 2_100_000, "2,10 Mio. Spieler", "Viral im Januar 2024")
        add("Counter-Strike 2", "Steam-Peak", "gaming", "players", 1_820_000, "1,82 Mio. Spieler", "Nachfolger von CS:GO")
        add("Lost Ark", "Steam-Peak", "gaming", "players", 1_325_000, "1,32 Mio. Spieler", "MMO-Launch 2022")
        add("Dota 2", "Steam-Peak", "gaming", "players", 1_295_000, "1,30 Mio. Spieler", "Free-to-Play-Klassiker")
        add("Cyberpunk 2077", "Steam-Peak", "gaming", "players", 1_054_000, "1,05 Mio. Spieler", "Launch-Peak 2020")
        add("Elden Ring", "Steam-Peak", "gaming", "players", 953_000, "953 Tsd. Spieler", "Launch-Peak 2022")
        add("New World", "Steam-Peak", "gaming", "players", 913_000, "913 Tsd. Spieler", "Amazons MMO-Launch")
        add("Hogwarts Legacy", "Steam-Peak", "gaming", "players", 879_000, "879 Tsd. Spieler", "Launch im Februar 2023")
        add("Baldur's Gate 3", "Steam-Peak", "gaming", "players", 875_000, "875 Tsd. Spieler", "Launch im August 2023")
        add("Goose Goose Duck", "Steam-Peak", "gaming", "players", 702_000, "702 Tsd. Spieler", "Among-Us-ähnliches Spiel")
        add("Apex Legends", "Steam-Peak", "gaming", "players", 624_000, "624 Tsd. Spieler", "Battle-Royale-Hit")
        add("Helldivers 2", "Steam-Peak", "gaming", "players", 458_000, "458 Tsd. Spieler", "Co-op-Shooter 2024")
        add("Monster Hunter: World", "Steam-Peak", "gaming", "players", 334_000, "334 Tsd. Spieler", "Capcoms Bestseller")
        add("ARK: Survival Evolved", "Steam-Peak", "gaming", "players", 252_000, "252 Tsd. Spieler", "Dinosaurier-Survival")
        add("Team Fortress 2", "Steam-Peak", "gaming", "players", 250_000, "250 Tsd. Spieler", "Valve-Klassiker")
        add("Rust", "Steam-Peak", "gaming", "players", 245_000, "245 Tsd. Spieler", "Multiplayer-Survival")
        add("Naraka: Bladepoint", "Steam-Peak", "gaming", "players", 218_000, "218 Tsd. Spieler", "Battle-Royale aus China")
        add("EA Sports FC 24", "Steam-Peak", "gaming", "players", 154_000, "154 Tsd. Spieler", "Nachfolger der FIFA-Reihe")
        add("Stardew Valley", "Steam-Peak", "gaming", "players", 95_000, "95 Tsd. Spieler", "Indie-Farming-Hit")

        // ============================================================
        // GAMING — Release-Jahr
        // ============================================================
        add("Pong", "Atari, Arcade", "gaming", "release_year", 1972, "1972", "Eines der ersten Videospiele")
        add("Space Invaders", "Taito, Arcade", "gaming", "release_year", 1978, "1978", "Shooter-Pionier")
        add("Pac-Man", "Namco, Arcade", "gaming", "release_year", 1980, "1980", "Spielhallen-Ikone")
        add("Donkey Kong", "Nintendo, Arcade", "gaming", "release_year", 1981, "1981", "Mario's erstes Spiel")
        add("Tetris", "Aljoschin Pajitnov", "gaming", "release_year", 1984, "1984", "Erfunden in der UdSSR")
        add("Super Mario Bros.", "Nintendo, NES", "gaming", "release_year", 1985, "1985", "Klassiker der NES-Ära")
        add("The Legend of Zelda", "Nintendo, NES", "gaming", "release_year", 1986, "1986", "Start der Zelda-Reihe")
        add("Sonic the Hedgehog", "Sega, Mega Drive", "gaming", "release_year", 1991, "1991", "Segas Maskottchen")
        add("Doom", "id Software", "gaming", "release_year", 1993, "1993", "FPS-Pionier")
        add("Pokémon Rot/Blau", "Nintendo, Game Boy", "gaming", "release_year", 1996, "1996", "Start des Pokémon-Hypes")
        add("Half-Life", "Valve", "gaming", "release_year", 1998, "1998", "FPS-Meilenstein")
        add("Die Sims", "Maxis", "gaming", "release_year", 2000, "2000", "Lebenssimulation")
        add("World of Warcraft", "Blizzard", "gaming", "release_year", 2004, "2004", "MMORPG-Klassiker")
        add("Half-Life 2", "Valve", "gaming", "release_year", 2004, "2004", "FPS-Meisterwerk")
        add("Minecraft", "Mojang", "gaming", "release_year", 2011, "2011", "Sandbox-Phänomen")
        add("Skyrim", "Bethesda", "gaming", "release_year", 2011, "2011", "11.11.11")
        add("GTA V", "Rockstar Games", "gaming", "release_year", 2013, "2013", "Bestseller bis heute")
        add("The Witcher 3: Wild Hunt", "CD Projekt", "gaming", "release_year", 2015, "2015", "RPG-GOTY 2015")
        add("Overwatch", "Blizzard", "gaming", "release_year", 2016, "2016", "Hero-Shooter")
        add("Fortnite", "Epic Games", "gaming", "release_year", 2017, "2017", "Battle Royale-Hit")
        add("Red Dead Redemption 2", "Rockstar Games", "gaming", "release_year", 2018, "2018", "Western-Open-World")
        add("Cyberpunk 2077", "CD Projekt", "gaming", "release_year", 2020, "2020", "Holpriger Launch")
        add("Elden Ring", "FromSoftware", "gaming", "release_year", 2022, "2022", "Open-World-Soulslike")
        add("Hogwarts Legacy", "Avalanche", "gaming", "release_year", 2023, "2023", "Harry-Potter-RPG")
        add("Baldur's Gate 3", "Larian", "gaming", "release_year", 2023, "2023", "GOTY 2023")

        // ============================================================
        // GAMING — Bewertung (Metacritic-Score)
        // ============================================================
        add("The Legend of Zelda: Ocarina of Time", "N64, 1998", "gaming", "rating", 99, "99/100", "Höchste Wertung aller Zeiten")
        add("Tony Hawk's Pro Skater 2", "PS1, 2000", "gaming", "rating", 98, "98/100", "Skater-Klassiker")
        add("Grand Theft Auto IV", "PS3, 2008", "gaming", "rating", 98, "98/100", "Liberty City")
        add("SoulCalibur", "Dreamcast, 1999", "gaming", "rating", 98, "98/100", "Fighting-Game-Klassiker")
        add("Super Mario Galaxy", "Wii, 2007", "gaming", "rating", 97, "97/100", "Schwerkraft-Spiel")
        add("Red Dead Redemption 2", "PS4, 2018", "gaming", "rating", 97, "97/100", "Western-Epos")
        add("Grand Theft Auto V", "PS3, 2013", "gaming", "rating", 97, "97/100", "Los Santos")
        add("Metroid Prime", "GameCube, 2002", "gaming", "rating", 97, "97/100", "First-Person-Adventure")
        add("BioShock", "X360, 2007", "gaming", "rating", 96, "96/100", "Rapture-Atmosphäre")
        add("Half-Life 2", "PC, 2004", "gaming", "rating", 96, "96/100", "City 17")
        add("Mass Effect 2", "X360, 2010", "gaming", "rating", 96, "96/100", "Space-Opera-RPG")
        add("Elden Ring", "PC, 2022", "gaming", "rating", 96, "96/100", "Open-World-Soulslike")
        add("Baldur's Gate 3", "PC, 2023", "gaming", "rating", 96, "96/100", "D&D-RPG")
        add("The Last of Us", "PS3, 2013", "gaming", "rating", 95, "95/100", "Post-Apokalypse")
        add("Persona 5 Royal", "PS4, 2020", "gaming", "rating", 95, "95/100", "JRPG-Meisterwerk")
        add("Portal 2", "PC, 2011", "gaming", "rating", 95, "95/100", "Puzzle-Klassiker")
        add("The Elder Scrolls V: Skyrim", "PC, 2011", "gaming", "rating", 94, "94/100", "Open-World-RPG")
        add("Hades", "PC, 2020", "gaming", "rating", 93, "93/100", "Roguelike der Stunde")
        add("Minecraft", "PC, 2011", "gaming", "rating", 93, "93/100", "Sandbox-Phänomen")
        add("The Witcher 3: Wild Hunt", "PC, 2015", "gaming", "rating", 93, "93/100", "Geralt-Abenteuer")
        add("Hollow Knight", "PC, 2017", "gaming", "rating", 90, "90/100", "Metroidvania-Hit")
        add("Cyberpunk 2077", "PC, 2020", "gaming", "rating", 86, "86/100", "Launch-Wertung PC")
        add("Hogwarts Legacy", "PC, 2023", "gaming", "rating", 84, "84/100", "Harry-Potter-RPG")
        add("Fortnite", "PC, 2017", "gaming", "rating", 78, "78/100", "Battle-Royale-Phänomen")
        add("No Man's Sky", "PC, 2016 (Launch)", "gaming", "rating", 71, "71/100", "Inzwischen deutlich besser")

        // ============================================================
        // GEOGRAFIE — Fläche (km²)
        // ============================================================
        add("Russland", "Land", "geography", "area", 17_098_242, "17,1 Mio. km²", "Größtes Land der Erde")
        add("Kanada", "Land", "geography", "area", 9_984_670, "9,98 Mio. km²", "Zweitgrößtes Land")
        add("USA", "Land", "geography", "area", 9_833_517, "9,83 Mio. km²", "Drittgrößtes Land")
        add("China", "Land", "geography", "area", 9_596_961, "9,60 Mio. km²", "Bevölkerungsreichstes Land")
        add("Brasilien", "Land", "geography", "area", 8_515_767, "8,52 Mio. km²", "Größtes Land Südamerikas")
        add("Australien", "Land", "geography", "area", 7_692_024, "7,69 Mio. km²", "Land und Kontinent")
        add("Indien", "Land", "geography", "area", 3_287_263, "3,29 Mio. km²", "Siebtgrößtes Land")
        add("Argentinien", "Land", "geography", "area", 2_780_400, "2,78 Mio. km²", "Achtgrößtes Land")
        add("Kasachstan", "Land", "geography", "area", 2_724_900, "2,72 Mio. km²", "Größter Binnenstaat")
        add("Algerien", "Land", "geography", "area", 2_381_741, "2,38 Mio. km²", "Größtes Land Afrikas")
        add("DR Kongo", "Land", "geography", "area", 2_344_858, "2,34 Mio. km²", "Zweitgrößtes Land Afrikas")
        add("Mexiko", "Land", "geography", "area", 1_964_375, "1,96 Mio. km²", "13.-größtes Land")
        add("Frankreich", "Land", "geography", "area", 643_801, "643.801 km²", "Größtes Land der EU")
        add("Spanien", "Land", "geography", "area", 505_990, "505.990 km²", "Iberische Halbinsel")
        add("Deutschland", "Land", "geography", "area", 357_588, "357.588 km²", "Mitten in Europa")
        add("Italien", "Land", "geography", "area", 301_340, "301.340 km²", "Stiefelförmiges Land")
        add("Bayern", "Bundesland", "geography", "area", 70_550, "70.550 km²", "Größtes Bundesland")
        add("Niedersachsen", "Bundesland", "geography", "area", 47_614, "47.614 km²", "Zweitgrößtes Bundesland")
        add("Baden-Württemberg", "Bundesland", "geography", "area", 35_751, "35.751 km²", "Im Südwesten")
        add("Nordrhein-Westfalen", "Bundesland", "geography", "area", 34_113, "34.113 km²", "Bevölkerungsreichstes Bundesland")
        add("Berlin", "Stadt-Bundesland", "geography", "area", 891, "891 km²", "Hauptstadt Deutschlands")
        add("Bremen", "Stadt-Bundesland", "geography", "area", 419, "419 km²", "Kleinstes Flächen-Bundesland")
        add("Liechtenstein", "Land", "geography", "area", 160, "160 km²", "Sechstkleinstes Land")
        add("San Marino", "Land", "geography", "area", 61, "61 km²", "Älteste Republik der Welt")
        add("Monaco", "Land", "geography", "area", 2, "2 km²", "Zweitkleinstes Land")

        // ============================================================
        // GEOGRAFIE — Einwohner (Städte & Länder)
        // ============================================================
        add("Indien", "Land", "geography", "population", 1_430_000_000, "1,43 Mrd. Einwohner", "Bevölkerungsreichstes Land 2025")
        add("China", "Land", "geography", "population", 1_410_000_000, "1,41 Mrd. Einwohner", "Bevölkerungsrückgang seit 2022")
        add("USA", "Land", "geography", "population", 333_000_000, "333 Mio. Einwohner", "Drittgrößte Bevölkerung")
        add("Indonesien", "Land", "geography", "population", 277_000_000, "277 Mio. Einwohner", "Größter Inselstaat")
        add("Pakistan", "Land", "geography", "population", 240_000_000, "240 Mio. Einwohner", "Fünftgrößtes Land")
        add("Brasilien", "Land", "geography", "population", 215_000_000, "215 Mio. Einwohner", "Größtes Land Südamerikas")
        add("Russland", "Land", "geography", "population", 144_000_000, "144 Mio. Einwohner", "Flächenmäßig größtes Land")
        add("Mexiko", "Land", "geography", "population", 128_000_000, "128 Mio. Einwohner", "Zehntgrößtes Land")
        add("Japan", "Land", "geography", "population", 124_000_000, "124 Mio. Einwohner", "Schrumpfende Bevölkerung")
        add("Deutschland", "Land", "geography", "population", 84_000_000, "84 Mio. Einwohner", "Bevölkerungsreichstes EU-Land")
        add("Frankreich", "Land", "geography", "population", 68_000_000, "68 Mio. Einwohner", "Zweitgrößte EU-Bevölkerung")
        add("Berlin", "Stadt", "geography", "population", 3_780_000, "3,78 Mio. Einwohner", "Größte deutsche Stadt")
        add("Hamburg", "Stadt", "geography", "population", 1_900_000, "1,90 Mio. Einwohner", "Größter deutscher Hafen")
        add("München", "Stadt", "geography", "population", 1_510_000, "1,51 Mio. Einwohner", "Hauptstadt Bayerns")
        add("Köln", "Stadt", "geography", "population", 1_080_000, "1,08 Mio. Einwohner", "Viertgrößte deutsche Stadt")
        add("Frankfurt am Main", "Stadt", "geography", "population", 770_000, "770 Tsd. Einwohner", "Finanzhauptstadt Deutschlands")
        add("Stuttgart", "Stadt", "geography", "population", 630_000, "630 Tsd. Einwohner", "Hauptstadt Baden-Württembergs")
        add("Leipzig", "Stadt", "geography", "population", 620_000, "620 Tsd. Einwohner", "Wachstumsstadt im Osten")
        add("Düsseldorf", "Stadt", "geography", "population", 620_000, "620 Tsd. Einwohner", "Hauptstadt NRWs")
        add("Dortmund", "Stadt", "geography", "population", 590_000, "590 Tsd. Einwohner", "Stadt der Borussen")
        add("Essen", "Stadt", "geography", "population", 580_000, "580 Tsd. Einwohner", "Im Herzen des Ruhrgebiets")
        add("Bremen", "Stadt", "geography", "population", 570_000, "570 Tsd. Einwohner", "Hansestadt im Norden")

        // ============================================================
        // GEOGRAFIE — Höhe (Berge & Bauwerke in m)
        // ============================================================
        add("Mount Everest", "Berg, Nepal/China", "geography", "height", 8848, "8.848 m", "Höchster Berg der Erde")
        add("K2", "Berg, Pakistan/China", "geography", "height", 8611, "8.611 m", "Zweithöchster Berg")
        add("Mont Blanc", "Berg, Frankreich/Italien", "geography", "height", 4810, "4.810 m", "Höchster Alpenberg")
        add("Matterhorn", "Berg, Schweiz/Italien", "geography", "height", 4478, "4.478 m", "Ikonisches Alpenmotiv")
        add("Großglockner", "Berg, Österreich", "geography", "height", 3798, "3.798 m", "Höchster Berg Österreichs")
        add("Zugspitze", "Berg, Deutschland", "geography", "height", 2962, "2.962 m", "Höchster Berg Deutschlands")
        add("Watzmann", "Berg, Deutschland", "geography", "height", 2713, "2.713 m", "Berchtesgadener Alpen")
        add("Brocken", "Berg, Deutschland", "geography", "height", 1141, "1.141 m", "Höchster Berg des Harzes")
        add("Großer Feldberg", "Berg, Deutschland", "geography", "height", 879, "879 m", "Höchster Berg des Taunus")
        add("Burj Khalifa", "Hochhaus, Dubai", "geography", "height", 828, "828 m", "Höchstes Bauwerk der Erde")
        add("Tokyo Skytree", "Fernsehturm, Tokio", "geography", "height", 634, "634 m", "Höchster Fernsehturm")
        add("CN Tower", "Fernsehturm, Toronto", "geography", "height", 553, "553 m", "Wahrzeichen Torontos")
        add("One World Trade Center", "Hochhaus, New York", "geography", "height", 541, "541 m", "Symbolische 1776 ft")
        add("Empire State Building", "Hochhaus, New York", "geography", "height", 381, "381 m", "Art-déco-Klassiker")
        add("Berliner Fernsehturm", "Fernsehturm, Berlin", "geography", "height", 368, "368 m", "Höchstes Bauwerk Deutschlands")
        add("Eiffelturm", "Turm, Paris", "geography", "height", 330, "330 m", "Wahrzeichen von Paris")
        add("Ulmer Münster", "Kirche, Ulm", "geography", "height", 161, "161 m", "Höchster Kirchturm der Welt")
        add("Kölner Dom", "Kathedrale, Köln", "geography", "height", 157, "157 m", "UNESCO-Welterbe")
        add("Cheops-Pyramide", "Pyramide, Ägypten", "geography", "height", 139, "139 m", "Letztes der sieben Weltwunder")
        add("Frauenkirche München", "Kirche, München", "geography", "height", 99, "99 m", "Wahrzeichen Münchens")
        add("Freiheitsstatue", "Statue, New York", "geography", "height", 93, "93 m", "Mit Sockel")
        add("Brandenburger Tor", "Tor, Berlin", "geography", "height", 26, "26 m", "Wahrzeichen Berlins")

        // ============================================================
        // GEOGRAFIE — Distanz (Luftlinie zwischen Städten in km)
        // ============================================================
        add("Berlin → Sydney", "Luftlinie", "geography", "distance", 16_100, "16.100 km", "Fast Antipode")
        add("Berlin → Tokio", "Luftlinie", "geography", "distance", 8_918, "8.918 km", "Quer über Asien")
        add("Berlin → Peking", "Luftlinie", "geography", "distance", 7_370, "7.370 km", "Reise nach Fernost")
        add("Berlin → New York", "Luftlinie", "geography", "distance", 6_385, "6.385 km", "Über den Atlantik")
        add("Berlin → Madrid", "Luftlinie", "geography", "distance", 1_869, "1.869 km", "Quer durch Europa")
        add("Berlin → Moskau", "Luftlinie", "geography", "distance", 1_620, "1.620 km", "Richtung Osten")
        add("München → Athen", "Luftlinie", "geography", "distance", 1_494, "1.494 km", "Vom Süden nach Süden")
        add("Berlin → Rom", "Luftlinie", "geography", "distance", 1_184, "1.184 km", "Über die Alpen")
        add("Berlin → Helsinki", "Luftlinie", "geography", "distance", 1_108, "1.108 km", "Hoch in den Norden")
        add("Berlin → London", "Luftlinie", "geography", "distance", 933, "933 km", "Insel-Verbindung")
        add("Berlin → Paris", "Luftlinie", "geography", "distance", 878, "878 km", "EU-Schwergewichte")
        add("München → Rom", "Luftlinie", "geography", "distance", 760, "760 km", "Klassische Italienreise")
        add("Berlin → Zürich", "Luftlinie", "geography", "distance", 670, "670 km", "Bis ans Mittelland")
        add("Hamburg → München", "Straße", "geography", "distance", 612, "612 km", "Norden trifft Süden")
        add("Berlin → Amsterdam", "Luftlinie", "geography", "distance", 577, "577 km", "Hinüber an die Nordsee")
        add("Berlin → München", "Straße", "geography", "distance", 504, "504 km", "Quer durch Deutschland")
        add("Berlin → Köln", "Straße", "geography", "distance", 477, "477 km", "Berlin trifft den Rhein")
        add("Köln → München", "Straße", "geography", "distance", 456, "456 km", "Rheinland nach Bayern")
        add("Berlin → Frankfurt", "Straße", "geography", "distance", 423, "423 km", "In die Mainmetropole")
        add("München → Wien", "Straße", "geography", "distance", 358, "358 km", "Bayerische Donauroute")
        add("Berlin → Hamburg", "Straße", "geography", "distance", 288, "288 km", "Klassischer A24-Trip")
        add("München → Zürich", "Straße", "geography", "distance", 244, "244 km", "Bayern nach Schweiz")
        add("Frankfurt → Stuttgart", "Straße", "geography", "distance", 153, "153 km", "Süddeutsche Achse")

        return list
    }

    fun mainCategory(categoryId: String): MainCategory? = categoriesById[categoryId]

    fun subCategory(categoryId: String, subCategoryId: String): SubCategory? =
        subCategoriesByKey["${categoryId}_$subCategoryId"]

    fun subCategoriesFor(categoryId: String): List<SubCategory> =
        subCategories.filter { it.categoryId == categoryId }

    fun itemsForSubCategory(categoryId: String, subCategoryId: String): List<ComparisonItem> =
        items.filter { it.categoryId == categoryId && it.subcategoryId == subCategoryId }

    fun itemCount(categoryId: String, subCategoryId: String): Int =
        itemsForSubCategory(categoryId, subCategoryId).size

    fun fallbackImageForSubCategory(categoryId: String, subCategoryId: String): CatalogImage? {
        val subCategory = subCategory(categoryId, subCategoryId) ?: return null
        return fallbackImagesBySubCategory[subCategory.metricId]?.toCatalogImage()
    }

    private fun buildItem(
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
        val image = geographyPopulationImageFor(title, categoryId, subcategoryId)
            ?: imagesByTitle[title]
            ?: footballImageFor(title, categoryId, subcategoryId)
            ?: fallbackImagesBySubCategory[subCategory.metricId]
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
            funFact = funFact,
            imageUrl = image?.imageUrl,
            imageSource = image?.imageSource,
            imageAuthor = image?.imageAuthor,
            imageAttributionText = image?.imageAttributionText,
            imageLicenseUrl = image?.imageLicenseUrl,
            imageSearchQuery = image?.imageSearchQuery,
            imageVerified = image?.imageVerified ?: false
        )
    }

    private fun footballImageFor(title: String, categoryId: String, subcategoryId: String): ImageMetadata? {
        if (categoryId != "football") return null
        return when (subcategoryId) {
            "stadium_capacity" -> footballStadiumImagesByTitle[title]
            "attendance" -> footballAttendanceImagesByTitle[title]
                ?: footballStadiumImagesByTitle[title]
                ?: footballClubImagesByTitle[title]
            else -> footballClubImagesByTitle[title]
        }
    }

    private fun geographyPopulationImageFor(title: String, categoryId: String, subcategoryId: String): ImageMetadata? {
        if (categoryId != "geography" || subcategoryId != "population") return null
        return geographyPopulationImagesByTitle[title]
    }

    private fun pexelsImage(
        photoId: Int,
        author: String,
        searchQuery: String,
        description: String
    ) = ImageMetadata(
        imageUrl = "https://images.pexels.com/photos/$photoId/pexels-photo-$photoId.jpeg?auto=compress&cs=tinysrgb&w=1200",
        imageSource = "Pexels",
        imageAuthor = author,
        imageAttributionText = "Photo by $author on Pexels ($description)",
        imageLicenseUrl = PEXELS_LICENSE_URL,
        imageSearchQuery = searchQuery
    )

    private fun localImage(
        resourceName: String,
        description: String
    ) = ImageMetadata(
        imageUrl = "android.resource://com.example.androidapptest/drawable/$resourceName",
        imageSource = "Local asset",
        imageAuthor = null,
        imageAttributionText = "Local image ($description)",
        imageLicenseUrl = "",
        imageSearchQuery = description
    )

    private fun wikimediaPhoto(
        fileName: String,
        author: String?,
        description: String,
        license: String
    ) = wikimediaImage(
        fileName = fileName,
        author = author,
        searchQuery = "$description Wikimedia Commons",
        description = description,
        license = license
    )

    private fun wikimediaImage(
        fileName: String,
        author: String?,
        searchQuery: String,
        description: String,
        license: String
    ) = ImageMetadata(
        imageUrl = wikimediaThumbnailUrl(fileName),
        imageSource = "Wikimedia Commons",
        imageAuthor = author,
        imageAttributionText = if (author != null) {
            "Image by $author on Wikimedia Commons ($description, $license)"
        } else {
            "Image on Wikimedia Commons ($description, $license)"
        },
        imageLicenseUrl = wikimediaFilePageUrl(fileName),
        imageSearchQuery = searchQuery
    )

    private fun ImageMetadata.toCatalogImage() = CatalogImage(
        imageUrl = imageUrl,
        imageAttributionText = imageAttributionText,
        imageSearchQuery = imageSearchQuery,
        imageVerified = imageVerified
    )

    private fun pixabayImage(
        imageUrl: String,
        author: String?,
        searchQuery: String,
        description: String
    ) = ImageMetadata(
        imageUrl = imageUrl,
        imageSource = "Pixabay",
        imageAuthor = author,
        imageAttributionText = if (author != null) {
            "Image by $author on Pixabay ($description)"
        } else {
            "Image on Pixabay ($description)"
        },
        imageLicenseUrl = PIXABAY_LICENSE_URL,
        imageSearchQuery = searchQuery
    )

    private fun wikimediaThumbnailUrl(fileName: String, width: Int = 1200): String {
        val encodedFileName = fileName.replace(' ', '_').urlEncode()
        return "https://commons.wikimedia.org/wiki/Special:Redirect/file/$encodedFileName?width=$width"
    }

    private fun wikimediaFilePageUrl(fileName: String): String =
        "https://commons.wikimedia.org/wiki/File:${fileName.replace(' ', '_').urlEncode()}"

    private fun String.urlEncode(): String =
        URLEncoder.encode(this, Charsets.UTF_8.name()).replace("+", "_")
}
